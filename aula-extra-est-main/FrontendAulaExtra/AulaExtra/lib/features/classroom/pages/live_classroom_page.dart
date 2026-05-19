import 'dart:async';
import 'dart:math' as math;

import 'package:aula_extra/core/data/communication/chat_files_service.dart';
import 'package:aula_extra/core/data/communication/realtime_chat_service.dart';
import 'package:aula_extra/core/data/lesson_classroom/dtos/lesson_classroom_entry_dto.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/classroom/widgets/whiteboard_panel.dart';
import 'package:aula_extra/features/professor/chats/widgets/chat_bubble.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

enum ClassroomFocusMode { grid, screen, whiteboard }

class LiveClassroomPage extends StatefulWidget {
  const LiveClassroomPage({super.key, required this.entry});

  final LessonClassroomEntryDto entry;

  @override
  State<LiveClassroomPage> createState() => _LiveClassroomPageState();
}

class _LiveClassroomPageState extends State<LiveClassroomPage> {
  static const int _maxChatFileSizeBytes = 5 * 1024 * 1024;

  final Set<int> _remoteUids = <int>{};
  final UsersService _usersService = UsersService();
  final ChatFilesService _chatFilesService = ChatFilesService();
  final RealtimeChatService _realtimeChatService = RealtimeChatService();
  final TextEditingController _chatComposerController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  StreamSubscription<RealtimeChatEvent>? _chatSubscription;
  Timer? _callTimer;

  RtcEngineEx? _engine;
  int? _remoteScreenShareUid;
  bool _joined = false;
  bool _loading = false;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isScreenSharing = false;
  bool _localScreenShareActive = false;
  bool _stoppingScreenShare = false;
  bool _screenShareConnectionJoined = false;
  String? _error;
  String? _chatError;
  String? _chatChannelName;
  String? _chatUsername;
  DateTime? _callStartedAt;
  bool _chatInitializing = false;
  bool _chatSending = false;
  bool _isChatPanelOpen = false;
  ClassroomFocusMode _focusMode = ClassroomFocusMode.grid;
  ClassroomFocusMode? _focusModeBeforeScreenShare;
  List<RealtimeChatMessage> _chatMessages = const <RealtimeChatMessage>[];

  int? get _localScreenShareUid => widget.entry.screenShare?.uid;

  bool get _isLocalScreenShareActive =>
      _localScreenShareActive || _isScreenSharing;

  bool get _hasScreenShare =>
      _isLocalScreenShareActive || _remoteScreenShareUid != null;

  bool get _whiteboardEnabled => widget.entry.whiteboard.isReady;

  bool get _captureSystemAudio => !kIsWeb;

  String get _fallbackLessonChatChannelName {
    final normalizedReservationId = widget.entry.reservationId
        .replaceAll('-', '')
        .trim()
        .toLowerCase();
    if (normalizedReservationId.isEmpty) {
      return '';
    }

    return 'group_lesson_$normalizedReservationId';
  }

  String get _resolvedLessonChatChannelName {
    final explicitChannelName = widget.entry.chatChannelName.trim();
    if (explicitChannelName.isNotEmpty) {
      return explicitChannelName;
    }

    return _fallbackLessonChatChannelName;
  }

  String get _callDurationLabel {
    final startedAt = _callStartedAt;
    if (startedAt == null) {
      return '00:00';
    }

    final elapsed = DateTime.now().difference(startedAt);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }

    return '${elapsed.inMinutes.toString().padLeft(2, '0')}:$seconds';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinClassroom();
      _initializeLessonChat();
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _callTimer?.cancel();
    _chatComposerController.dispose();
    _chatScrollController.dispose();
    _engine?.release();
    super.dispose();
  }

  bool get _hasLessonChat => _resolvedLessonChatChannelName.isNotEmpty;

  bool get _canToggleLessonChat =>
      _hasLessonChat ||
      (_chatChannelName?.trim().isNotEmpty ?? false) ||
      _chatInitializing;

  Future<void> _toggleChatPanel() async {
    if (_isChatPanelOpen) {
      setState(() => _isChatPanelOpen = false);
      return;
    }

    if ((_chatChannelName?.trim().isEmpty ?? true) && _hasLessonChat) {
      await _initializeLessonChat();
    }

    if (!mounted) return;

    if ((_chatChannelName?.trim().isNotEmpty ?? false) || _hasLessonChat) {
      setState(() {
        _isChatPanelOpen = true;
      });
      return;
    }

    setState(() {
      _chatError = 'Não foi possível abrir o chat desta aula.';
      _isChatPanelOpen = true;
    });
  }

  Future<void> _initializeLessonChat() async {
    if (!_hasLessonChat || _chatInitializing) return;

    setState(() {
      _chatInitializing = true;
      _chatError = null;
    });

    try {
      var username = context.read<UserProvider>().account?.username?.trim();
      var displayName = context.read<UserProvider>().account?.fullName?.trim();

      if (username == null || username.isEmpty) {
        final me = await _usersService.getMe();
        username = me.username?.trim();
        displayName = me.displayName?.trim();
      }

      if (username == null || username.isEmpty) {
        throw Exception('Não foi possível identificar o utilizador no chat.');
      }

      displayName = (displayName == null || displayName.isEmpty)
          ? username
          : displayName;

      _chatUsername = username;

      await _realtimeChatService.connect(
        username: username,
        displayName: displayName,
      );
      await _chatSubscription?.cancel();
      _chatSubscription = _realtimeChatService.events.listen(_onChatEvent);

      _chatChannelName = await _realtimeChatService.joinChannel(
        channelName: _resolvedLessonChatChannelName,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _chatError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _chatInitializing = false;
        });
      }
    }
  }

  void _onChatEvent(RealtimeChatEvent event) {
    if (!mounted) return;

    final expectedChannel = _chatChannelName?.trim().toLowerCase();
    if (expectedChannel == null || expectedChannel.isEmpty) {
      return;
    }

    if (event is RealtimeChatRoomJoined) {
      if (event.channelName.trim().toLowerCase() != expectedChannel) return;
      setState(() {
        _chatMessages = List<RealtimeChatMessage>.from(event.messages);
        _chatError = null;
      });
      _scrollChatToBottom();
      return;
    }

    if (event is RealtimeChatRoomHistoryLoaded) {
      if (event.channelName.trim().toLowerCase() != expectedChannel) return;
      setState(() {
        _chatMessages = List<RealtimeChatMessage>.from(event.messages);
      });
      _scrollChatToBottom();
      return;
    }

    if (event is RealtimeChatMessageReceived) {
      if (event.channelName.trim().toLowerCase() != expectedChannel) return;
      if (event.message.isSystemFileNotification) return;
      setState(() {
        _chatMessages = <RealtimeChatMessage>[
          ..._chatMessages,
          event.message,
        ];
        _chatError = null;
      });
      _scrollChatToBottom();
      return;
    }

    if (event is RealtimeChatError) {
      setState(() {
        _chatError = event.message;
      });
    }
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendLessonChatMessage() async {
    final channelName = _chatChannelName;
    final content = _chatComposerController.text.trim();
    if (channelName == null || channelName.isEmpty || content.isEmpty) {
      return;
    }

    setState(() {
      _chatSending = true;
      _chatError = null;
    });

    try {
      await _realtimeChatService.sendMessage(
        channelName: channelName,
        content: content,
      );
      _chatComposerController.clear();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _chatError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _chatSending = false;
        });
      }
    }
  }

  Future<void> _pickAndSendLessonFile() async {
    final channelName = _chatChannelName;
    final username = _chatUsername;
    if (channelName == null ||
        channelName.isEmpty ||
        username == null ||
        username.isEmpty) {
      return;
    }

    setState(() {
      _chatSending = true;
      _chatError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final pickedFile = result.files.single;
      final bytes = pickedFile.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw Exception('Não foi possível ler o ficheiro selecionado.');
      }

      if (bytes.length > _maxChatFileSizeBytes) {
        throw Exception('O ficheiro excede o limite de 5 MB.');
      }

      final uploaded = await _chatFilesService.uploadFile(
        bytes: bytes,
        fileName: pickedFile.name,
        contentType: _guessContentType(pickedFile.name),
        userId: username,
        roomId: channelName,
      );

      final caption = _chatComposerController.text.trim();
      await _realtimeChatService.sendFileMessage(
        channelName: channelName,
        fileId: uploaded.fileId,
        caption: caption.isEmpty ? null : caption,
      );

      _chatComposerController.clear();
      _scrollChatToBottom();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _chatError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _chatSending = false;
        });
      }
    }
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      setState(() {
        _chatError = 'Link do ficheiro inválido.';
      });
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      setState(() {
        _chatError = 'Não foi possível abrir o ficheiro.';
      });
    }
  }

  String _guessContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _ensurePermissions() async {
    if (kIsWeb) return;
    await <Permission>[Permission.microphone, Permission.camera].request();
  }

  bool _isScreenShareUid(int uid) => uid % 100 == 99;

  void _startCallTimer() {
    _callStartedAt ??= DateTime.now();
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _callStartedAt == null) return;
      setState(() {});
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  void _reconcileFocusMode() {
    if (_hasScreenShare) {
      _focusModeBeforeScreenShare ??= _focusMode;
      _focusMode = ClassroomFocusMode.screen;
      return;
    }

    final previousFocus = _focusModeBeforeScreenShare;
    _focusModeBeforeScreenShare = null;
    if (previousFocus == ClassroomFocusMode.whiteboard && _whiteboardEnabled) {
      _focusMode = ClassroomFocusMode.whiteboard;
      return;
    }

    if (_focusMode == ClassroomFocusMode.screen) {
      _focusMode = ClassroomFocusMode.grid;
    }
  }

  Future<RtcEngineEx> _createEngine() async {
    final engine = createAgoraRtcEngineEx();
    await engine.initialize(RtcEngineContext(appId: widget.entry.agoraAppId));
    await engine.enableAudio();
    await engine.enableVideo();
    await engine.setChannelProfile(
      ChannelProfileType.channelProfileLiveBroadcasting,
    );
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (error, message) {
          if (!mounted) return;
          setState(() => _error = '[Agora] $error: $message');
        },
        onJoinChannelSuccess: (connection, elapsed) {
          if (!mounted || connection.localUid != widget.entry.agoraUid) return;
          setState(() {
            _joined = true;
            _error = null;
          });
          _startCallTimer();
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          if (!mounted) return;
          setState(() {
            if (remoteUid == widget.entry.agoraUid) {
              return;
            }

            if (remoteUid == _localScreenShareUid) {
              _reconcileFocusMode();
              return;
            }

            _remoteUids.add(remoteUid);
            if (_isScreenShareUid(remoteUid)) {
              _remoteScreenShareUid = remoteUid;
              _reconcileFocusMode();
            }
          });
        },
        onUserOffline: (connection, remoteUid, reason) {
          if (!mounted) return;
          setState(() {
            _remoteUids.remove(remoteUid);
            if (_remoteScreenShareUid == remoteUid) {
              _remoteScreenShareUid = null;
              _reconcileFocusMode();
            }
          });
        },
        onLeaveChannel: (connection, stats) {
          if (!mounted) return;
          if (connection.localUid == _localScreenShareUid) {
            setState(() {
              final shareUid = _localScreenShareUid;
              if (shareUid != null) {
                _remoteUids.remove(shareUid);
                if (_remoteScreenShareUid == shareUid) {
                  _remoteScreenShareUid = null;
                }
              }
              _isScreenSharing = false;
              _localScreenShareActive = false;
              _reconcileFocusMode();
            });
            return;
          }

          if (connection.localUid != widget.entry.agoraUid) return;
          setState(() {
            _joined = false;
            _remoteUids.clear();
            _remoteScreenShareUid = null;
            _isScreenSharing = false;
            _localScreenShareActive = false;
            _screenShareConnectionJoined = false;
            _focusModeBeforeScreenShare = null;
            _focusMode = ClassroomFocusMode.grid;
          });
        },
        onLocalVideoStateChanged: (source, state, reason) {
          if (source != VideoSourceType.videoSourceScreen &&
              source != VideoSourceType.videoSourceScreenPrimary) {
            return;
          }

          final isSharing =
              state == LocalVideoStreamState.localVideoStreamStateCapturing ||
              state == LocalVideoStreamState.localVideoStreamStateEncoding;
          if (!mounted) return;

          setState(() {
            _isScreenSharing = isSharing;
            _localScreenShareActive = isSharing;
            _reconcileFocusMode();
          });

          if (!isSharing && !_stoppingScreenShare) {
            _stopScreenShare(fromExternalStop: true);
          }

          if (state == LocalVideoStreamState.localVideoStreamStateFailed) {
            setState(() => _error = '[ScreenShare] failed: $reason');
          }
        },
      ),
    );

    return engine;
  }

  Future<void> _joinClassroom() async {
    if (_joined || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _ensurePermissions();
      final engine = _engine ?? await _createEngine();
      _engine = engine;

      await engine.startPreview();
      await engine.joinChannelEx(
        token: widget.entry.rtcToken,
        connection: RtcConnection(
          channelId: widget.entry.channelName,
          localUid: widget.entry.agoraUid,
        ),
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      if (widget.entry.isHost && widget.entry.screenShare != null) {
        final screenShare = widget.entry.screenShare!;
        await engine.joinChannelEx(
          token: screenShare.token,
          connection: RtcConnection(
            channelId: widget.entry.channelName,
            localUid: screenShare.uid,
          ),
          options: const ChannelMediaOptions(
            autoSubscribeAudio: false,
            autoSubscribeVideo: false,
            publishScreenTrack: false,
            publishSecondaryScreenTrack: false,
            publishCameraTrack: false,
            publishMicrophoneTrack: false,
            publishScreenCaptureAudio: false,
            publishScreenCaptureVideo: false,
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
          ),
        );
        _screenShareConnectionJoined = true;
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _leaveClassroom() async {
    if (_engine == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isScreenSharing && widget.entry.screenShare != null) {
        await _stopScreenShare();
      }

      if (_screenShareConnectionJoined && widget.entry.screenShare != null) {
        try {
          await _engine!.leaveChannelEx(
            connection: RtcConnection(
              channelId: widget.entry.channelName,
              localUid: widget.entry.screenShare!.uid,
            ),
            options: const LeaveChannelOptions(),
          );
        } catch (_) {}
        _screenShareConnectionJoined = false;
      }

      await _engine!.leaveChannelEx(
        connection: RtcConnection(
          channelId: widget.entry.channelName,
          localUid: widget.entry.agoraUid,
        ),
        options: const LeaveChannelOptions(),
      );

      _stopCallTimer();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleMute() async {
    if (_engine == null) return;
    setState(() => _isMuted = !_isMuted);
    await _engine!.muteLocalAudioStream(_isMuted);
  }

  Future<void> _toggleVideo() async {
    if (_engine == null) return;
    setState(() => _isVideoOff = !_isVideoOff);
    await _engine!.muteLocalVideoStream(_isVideoOff);
  }

  Future<void> _startScreenShare() async {
    if (!widget.entry.isHost ||
        _engine == null ||
        widget.entry.screenShare == null) {
      return;
    }

    if (kIsWeb && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O navegador vai abrir o seletor nativo para escolher o ecrã ou janela a partilhar.',
          ),
        ),
      );
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final screenShare = widget.entry.screenShare!;

      if (!_screenShareConnectionJoined) {
        await _engine!.joinChannelEx(
          token: screenShare.token,
          connection: RtcConnection(
            channelId: widget.entry.channelName,
            localUid: screenShare.uid,
          ),
          options: const ChannelMediaOptions(
            autoSubscribeAudio: false,
            autoSubscribeVideo: false,
            publishScreenTrack: false,
            publishSecondaryScreenTrack: false,
            publishCameraTrack: false,
            publishMicrophoneTrack: false,
            publishScreenCaptureAudio: false,
            publishScreenCaptureVideo: false,
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
          ),
        );
        _screenShareConnectionJoined = true;
      }

      await _engine!.startScreenCapture(
        ScreenCaptureParameters2(
          captureAudio: _captureSystemAudio,
          captureVideo: true,
        ),
      );

      try {
        if (!kIsWeb) {
          await _engine!.startPreview(
            sourceType: VideoSourceType.videoSourceScreen,
          );
        }
      } catch (_) {}

      await _engine!.updateChannelMediaOptionsEx(
        options: ChannelMediaOptions(
          publishScreenTrack: true,
          publishSecondaryScreenTrack: false,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          publishScreenCaptureAudio: _captureSystemAudio,
          publishScreenCaptureVideo: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
        connection: RtcConnection(
          channelId: widget.entry.channelName,
          localUid: screenShare.uid,
        ),
      );

      if (!mounted) return;
      setState(() {
        _isScreenSharing = true;
        _localScreenShareActive = true;
        _reconcileFocusMode();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isScreenSharing = false;
        _localScreenShareActive = false;
        _error = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _stopScreenShare({bool fromExternalStop = false}) async {
    if (_engine == null ||
        widget.entry.screenShare == null ||
        _stoppingScreenShare) {
      return;
    }

    _stoppingScreenShare = true;
    if (!fromExternalStop) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final screenShare = widget.entry.screenShare!;

      await _engine!.updateChannelMediaOptionsEx(
        options: const ChannelMediaOptions(
          publishScreenTrack: false,
          publishSecondaryScreenTrack: false,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          publishScreenCaptureAudio: false,
          publishScreenCaptureVideo: false,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
        connection: RtcConnection(
          channelId: widget.entry.channelName,
          localUid: screenShare.uid,
        ),
      );

      try {
        await _engine!.stopScreenCapture();
      } catch (_) {}

      try {
        await _engine!.updateChannelMediaOptionsEx(
          options: const ChannelMediaOptions(
            publishCameraTrack: true,
            publishMicrophoneTrack: true,
            publishScreenTrack: false,
            publishSecondaryScreenTrack: false,
            publishScreenCaptureAudio: false,
            publishScreenCaptureVideo: false,
            autoSubscribeAudio: true,
            autoSubscribeVideo: true,
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
          ),
          connection: RtcConnection(
            channelId: widget.entry.channelName,
            localUid: widget.entry.agoraUid,
          ),
        );
      } catch (_) {}

      try {
        await _engine!.enableLocalVideo(true);
        await _engine!.startPreview();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _isScreenSharing = false;
        _localScreenShareActive = false;
        _reconcileFocusMode();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      _stoppingScreenShare = false;
      if (mounted && !fromExternalStop) {
        setState(() => _loading = false);
      }
    }
  }

  void _openWhiteboard() {
    if (!_whiteboardEnabled) {
      setState(
        () => _error = 'Whiteboard não está configurado para esta aula.',
      );
      return;
    }

    setState(() {
      _focusMode = ClassroomFocusMode.whiteboard;
      if (!_hasScreenShare) {
        _focusModeBeforeScreenShare = null;
      }
    });
  }

  void _closeWhiteboard() {
    setState(() {
      _focusMode = ClassroomFocusMode.grid;
      if (_focusModeBeforeScreenShare == ClassroomFocusMode.whiteboard) {
        _focusModeBeforeScreenShare = ClassroomFocusMode.grid;
      }
    });
  }

  Widget _buildContent() {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final isWideLayout = width >= 1100;
    final chatPanelWidth = math.min(360.0, math.max(300.0, width * 0.32));
    final chatInset = isWideLayout && _isChatPanelOpen ? chatPanelWidth + 16 : 0.0;
    final engine = _engine;
    final connection = RtcConnection(
      channelId: widget.entry.channelName,
      localUid: widget.entry.agoraUid,
    );

    final tiles = <Widget>[
      _VideoTile(
        label: '${widget.entry.localDisplayName} (você)',
        child: engine == null
            ? const _PlaceholderTile()
            : AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
      ),
      for (final uid in _remoteUids)
        if (uid != _remoteScreenShareUid)
          _VideoTile(
            label: widget.entry.remoteDisplayName,
            child: engine == null
                ? const _PlaceholderTile()
                : AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: engine,
                      canvas: VideoCanvas(uid: uid),
                      connection: connection,
                    ),
                  ),
          ),
    ];

    if (_focusMode == ClassroomFocusMode.grid) {
      return GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: MediaQuery.of(context).size.width >= 1100 ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 16 / 9,
        children: tiles,
      );
    }

    Widget centerStage;
    if (_focusMode == ClassroomFocusMode.whiteboard) {
      centerStage = WhiteboardPanel(
        appIdentifier: widget.entry.whiteboard.appIdentifier,
        region: widget.entry.whiteboard.region,
        uuid: widget.entry.whiteboard.uuid,
        roomToken: widget.entry.whiteboard.roomToken,
        uid: widget.entry.agoraUid,
      );
    } else if (_focusMode == ClassroomFocusMode.screen && engine != null) {
      if (_isLocalScreenShareActive) {
        if (kIsWeb && _localScreenShareUid != null) {
          centerStage = AgoraVideoView(
            controller: VideoViewController.remote(
              rtcEngine: engine,
              canvas: VideoCanvas(
                uid: _localScreenShareUid!,
                renderMode: RenderModeType.renderModeFit,
              ),
              connection: connection,
            ),
          );
        } else {
          centerStage = AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: engine,
              canvas: const VideoCanvas(
                uid: 0,
                sourceType: VideoSourceType.videoSourceScreen,
                renderMode: RenderModeType.renderModeFit,
              ),
            ),
          );
        }
      } else if (_remoteScreenShareUid != null) {
        centerStage = AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: engine,
            canvas: VideoCanvas(
              uid: _remoteScreenShareUid!,
              renderMode: RenderModeType.renderModeFit,
            ),
            connection: connection,
          ),
        );
      } else {
        centerStage = const _CenterStagePlaceholder(
          label: 'Nenhuma partilha de ecrã ativa',
        );
      }
    } else {
      centerStage = const _CenterStagePlaceholder(
        label: 'Nenhum conteúdo ativo',
      );
    }

    final stage = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: centerStage,
        ),
      ),
    );

    final participantsStrip = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: tiles.length,
          separatorBuilder: (context, index) => const SizedBox(width: 12),
          itemBuilder: (context, index) => SizedBox(
            width: isWideLayout ? 220 : 180,
            child: AspectRatio(aspectRatio: 16 / 9, child: tiles[index]),
          ),
        ),
      ),
    );

    final chatPanel = _LessonChatPanel(
      title: widget.entry.chatDisplayName.trim().isEmpty
          ? 'Chat da aula'
          : widget.entry.chatDisplayName,
      isOpen: _isChatPanelOpen,
      isLoading: _chatInitializing,
      isSending: _chatSending,
      errorMessage: _chatError,
      hasChat: _hasLessonChat,
      composerController: _chatComposerController,
      scrollController: _chatScrollController,
      messages: _chatMessages,
      currentUsername: _chatUsername,
      onAttach: _pickAndSendLessonFile,
      onClose: () => setState(() => _isChatPanelOpen = false),
      onAttachmentTap: _openExternalUrl,
      onSend: _sendLessonChatMessage,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      child: Stack(
        children: <Widget>[
          AnimatedPadding(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.only(right: chatInset),
            child: Column(
              children: <Widget>[
                Expanded(child: stage),
                const SizedBox(height: 16),
                SizedBox(height: isWideLayout ? 146 : 126, child: participantsStrip),
              ],
            ),
          ),
          if (!isWideLayout && _isChatPanelOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isChatPanelOpen = false),
                child: Container(color: const Color(0x33000000)),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: IgnorePointer(
              ignoring: !_isChatPanelOpen,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                offset: _isChatPanelOpen ? Offset.zero : const Offset(1.08, 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _isChatPanelOpen ? 1 : 0,
                  child: SizedBox(
                    width: isWideLayout ? chatPanelWidth : math.min(380, width - 18),
                    child: chatPanel,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F8),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                _ClassroomHeader(
                  title: widget.entry.lessonTitle.trim().isEmpty
                      ? 'Aula ao vivo'
                      : widget.entry.lessonTitle,
                  subtitle:
                      '${widget.entry.localDisplayName} · sala ${widget.entry.channelName}',
                  remoteDisplayName: widget.entry.remoteDisplayName,
                  participantCount: _remoteUids.length + 1,
                  callDurationLabel: _callDurationLabel,
                  hasChat: _hasLessonChat,
                  isChatOpen: _isChatPanelOpen,
                  isLoading: _loading,
                    onToggleChat: _canToggleLessonChat ? _toggleChatPanel : null,
                ),
                if (_error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE7E3),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFFC8BC)),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Color(0xFF8A2F1B)),
                    ),
                  ),
                Expanded(child: _buildContent()),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: _ClassroomControlsDock(
                isMuted: _isMuted,
                isVideoOff: _isVideoOff,
                isWhiteboardOpen: _focusMode == ClassroomFocusMode.whiteboard,
                isScreenSharing: _isLocalScreenShareActive,
                isChatOpen: _isChatPanelOpen,
                canShareScreen:
                    widget.entry.isHost &&
                    widget.entry.screenShare != null &&
                    !_hasScreenShare,
                canStopScreenShare:
                    widget.entry.isHost && _isLocalScreenShareActive,
                canOpenWhiteboard: _whiteboardEnabled && _joined,
                canToggleChat: _canToggleLessonChat,
                onLeave: _joined && !_loading ? _leaveClassroom : null,
                onToggleMute: _joined ? _toggleMute : null,
                onToggleVideo: _joined ? _toggleVideo : null,
                onOpenWhiteboard: _joined ? _openWhiteboard : null,
                onCloseWhiteboard: _joined ? _closeWhiteboard : null,
                onStartScreenShare: _joined ? _startScreenShare : null,
                onStopScreenShare: _joined ? _stopScreenShare : null,
                onToggleChat: _toggleChatPanel,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonChatPanel extends StatelessWidget {
  const _LessonChatPanel({
    required this.title,
    required this.isOpen,
    required this.isLoading,
    required this.isSending,
    required this.errorMessage,
    required this.hasChat,
    required this.composerController,
    required this.scrollController,
    required this.messages,
    required this.currentUsername,
    required this.onAttach,
    required this.onClose,
    required this.onAttachmentTap,
    required this.onSend,
  });

  final String title;
  final bool isOpen;
  final bool isLoading;
  final bool isSending;
  final String? errorMessage;
  final bool hasChat;
  final TextEditingController composerController;
  final ScrollController scrollController;
  final List<RealtimeChatMessage> messages;
  final String? currentUsername;
  final Future<void> Function() onAttach;
  final VoidCallback onClose;
  final Future<void> Function(String url) onAttachmentTap;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 32,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF16161B),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'As mensagens e ficheiros ficam disponíveis nos chats dos utilizadores.',
                        style: TextStyle(
                          color: Color(0xFF7B7E87),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Fechar chat',
                  onPressed: isOpen ? onClose : null,
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F8),
                    foregroundColor: const Color(0xFF4A4D57),
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8FB),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFEBEDF2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: !hasChat
                      ? const Center(
                          child: Text(
                            'O chat desta aula não está disponível.',
                            style: TextStyle(color: Color(0xFF7B7E87)),
                          ),
                        )
                      : isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : messages.isEmpty
                      ? const Center(
                          child: Text(
                            'Ainda não existem mensagens nesta aula.',
                            style: TextStyle(color: Color(0xFF7B7E87)),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          itemCount: messages.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMine = currentUsername != null &&
                                message.senderId.trim().toLowerCase() ==
                                    currentUsername!.trim().toLowerCase();
                            return ChatBubble(
                              text: message.content,
                              timeLabel: _formatChatTime(message.timestamp),
                              isMine: isMine,
                              maxWidth: 280,
                              attachment: message.attachment,
                              onAttachmentTap: message.attachment == null
                                  ? null
                                  : () => onAttachmentTap(
                                        message.attachment!.downloadUrl,
                                      ),
                            );
                          },
                        ),
                ),
              ),
            ),
            if (errorMessage != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                errorMessage!,
                style: const TextStyle(color: Color(0xFFD14343), fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FB),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFEBEDF2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      tooltip: 'Enviar ficheiro',
                      onPressed: hasChat && !isLoading && !isSending
                          ? onAttach
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFFFFF),
                        foregroundColor: const Color(0xFFFF6A3D),
                      ),
                      icon: const Icon(Icons.attach_file_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: composerController,
                        minLines: 1,
                        maxLines: 4,
                        enabled: hasChat && !isLoading && !isSending,
                        decoration: InputDecoration(
                          hintText: 'Escreva uma mensagem',
                          hintStyle: const TextStyle(color: Color(0xFF9EA2AD)),
                          border: InputBorder.none,
                          filled: false,
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed:
                          hasChat && !isLoading && !isSending ? onSend : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6A3D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassroomHeader extends StatelessWidget {
  const _ClassroomHeader({
    required this.title,
    required this.subtitle,
    required this.remoteDisplayName,
    required this.participantCount,
    required this.callDurationLabel,
    required this.hasChat,
    required this.isChatOpen,
    required this.isLoading,
    required this.onToggleChat,
  });

  final String title;
  final String subtitle;
  final String remoteDisplayName;
  final int participantCount;
  final String callDurationLabel;
  final bool hasChat;
  final bool isChatOpen;
  final bool isLoading;
  final VoidCallback? onToggleChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF18181C),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF6E717B)),
                ),
              ],
            ),
          ),
          _HeaderPill(
            icon: Icons.groups_rounded,
            label: '$participantCount participantes',
          ),
          const SizedBox(width: 10),
          _HeaderPill(
            icon: Icons.timer_outlined,
            label: callDurationLabel,
          ),
          const SizedBox(width: 10),
          _HeaderPill(
            icon: Icons.person_rounded,
            label: remoteDisplayName,
          ),
          const SizedBox(width: 8),
          if (hasChat)
            IconButton(
              tooltip: isChatOpen ? 'Fechar chat' : 'Abrir chat',
              onPressed: onToggleChat,
              style: IconButton.styleFrom(
                backgroundColor: isChatOpen
                    ? const Color(0xFFFFEEE8)
                    : const Color(0xFFF4F5F8),
                foregroundColor: isChatOpen
                    ? const Color(0xFFFF6A3D)
                    : const Color(0xFF4E515B),
              ),
              icon: Icon(
                isChatOpen ? Icons.chat_rounded : Icons.chat_bubble_outline_rounded,
              ),
            ),
          if (isLoading) ...<Widget>[
            const SizedBox(width: 10),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: const Color(0xFF5E616B)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF4A4D57),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassroomControlsDock extends StatelessWidget {
  const _ClassroomControlsDock({
    required this.isMuted,
    required this.isVideoOff,
    required this.isWhiteboardOpen,
    required this.isScreenSharing,
    required this.isChatOpen,
    required this.canShareScreen,
    required this.canStopScreenShare,
    required this.canOpenWhiteboard,
    required this.canToggleChat,
    required this.onLeave,
    required this.onToggleMute,
    required this.onToggleVideo,
    required this.onOpenWhiteboard,
    required this.onCloseWhiteboard,
    required this.onStartScreenShare,
    required this.onStopScreenShare,
    required this.onToggleChat,
  });

  final bool isMuted;
  final bool isVideoOff;
  final bool isWhiteboardOpen;
  final bool isScreenSharing;
  final bool isChatOpen;
  final bool canShareScreen;
  final bool canStopScreenShare;
  final bool canOpenWhiteboard;
  final bool canToggleChat;
  final VoidCallback? onLeave;
  final VoidCallback? onToggleMute;
  final VoidCallback? onToggleVideo;
  final VoidCallback? onOpenWhiteboard;
  final VoidCallback? onCloseWhiteboard;
  final VoidCallback? onStartScreenShare;
  final VoidCallback? onStopScreenShare;
  final VoidCallback? onToggleChat;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE8E8EE)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: <Widget>[
              _CallControlButton(
                tooltip: isMuted ? 'Ativar microfone' : 'Desativar microfone',
                icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                isActive: !isMuted,
                isAlert: isMuted,
                onPressed: onToggleMute,
              ),
              _CallControlButton(
                tooltip: isVideoOff ? 'Ativar câmara' : 'Desativar câmara',
                icon: isVideoOff
                    ? Icons.videocam_off_rounded
                    : Icons.videocam_rounded,
                isActive: !isVideoOff,
                isAlert: isVideoOff,
                onPressed: onToggleVideo,
              ),
              _CallControlButton(
                tooltip: isScreenSharing ? 'Parar partilha' : 'Partilhar ecrã',
                icon: isScreenSharing
                    ? Icons.stop_screen_share_rounded
                    : Icons.screen_share_rounded,
                isActive: isScreenSharing,
                onPressed: isScreenSharing
                    ? (canStopScreenShare ? onStopScreenShare : null)
                    : (canShareScreen ? onStartScreenShare : null),
              ),
              _CallControlButton(
                tooltip: isWhiteboardOpen
                    ? 'Fechar whiteboard'
                    : 'Abrir whiteboard',
                icon: isWhiteboardOpen
                    ? Icons.close_fullscreen_rounded
                    : Icons.draw_rounded,
                isActive: isWhiteboardOpen,
                onPressed: isWhiteboardOpen
                    ? onCloseWhiteboard
                    : (canOpenWhiteboard ? onOpenWhiteboard : null),
              ),
              _CallControlButton(
                tooltip: isChatOpen ? 'Fechar chat' : 'Abrir chat',
                icon: isChatOpen
                    ? Icons.chat_rounded
                    : Icons.chat_bubble_outline_rounded,
                isActive: isChatOpen,
                onPressed: onToggleChat,
              ),
              FilledButton.icon(
                onPressed: onLeave,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A3D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.call_end_rounded),
                label: const Text('Terminar chamada'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.isAlert = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isAlert
        ? const Color(0xFFFFEEE8)
        : isActive
        ? const Color(0xFFFFF2EC)
        : const Color(0xFFF4F5F8);
    final foregroundColor = isAlert
        ? const Color(0xFFD14343)
        : isActive
        ? const Color(0xFFFF6A3D)
        : const Color(0xFF4E515B);

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.all(16),
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF111827)),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: child),
            Positioned(
              left: 10,
              bottom: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('A ligar à aula…', style: TextStyle(color: Colors.white54)),
    );
  }
}

class _CenterStagePlaceholder extends StatelessWidget {
  const _CenterStagePlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF121212)),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
      ),
    );
  }
}

String _formatChatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
