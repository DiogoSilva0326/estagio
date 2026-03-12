import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/api_service.dart';
import '../widgets/whiteboard_panel.dart';
import '../widgets/chat_panel.dart';

enum FocusMode { none, screen, whiteboard }

class VideoChatPage extends StatefulWidget {
  final String channelName;
  final String userName;
  final String? authToken;
  final bool isHost;

  const VideoChatPage({
    super.key,
    required this.channelName,
    required this.userName,
    this.authToken,
    this.isHost = false,
  });

  @override
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  final _apiService = ApiService();
  final _remoteUids = <int>{};
  final _userNames = <int, String>{};
  final _sessionUsers = <String, SessionUser>{};

  late final TextEditingController _channelController;
  late final TextEditingController _nameController;

  RtcEngineEx? _engine;
  String _currentChannel = '';
  int _localUid = 0;
  int? _screenShareUid;
  int? _remoteScreenShareUid;
  bool _joined = false;

  bool _isScreenSharing = false;
  bool _stoppingScreenShare = false;

  FocusMode? _focusModeBeforeScreenShare;
  FocusMode _focusMode = FocusMode.none;
  
  // Whiteboard data
  String? _whiteboardUuid;
  String? _whiteboardRoomToken;

  bool _loading = false;
  String? _error;

  // Audio/Video state
  bool _isMuted = false;
  bool _isVideoOff = false;

  // Chat panel state
  bool _isChatOpen = false;

  @override
  void initState() {
    super.initState();
    _channelController = TextEditingController(text: widget.channelName);
    _nameController = TextEditingController(text: widget.userName);
    
    // Auto-join on init
    WidgetsBinding.instance.addPostFrameCallback((_) => _join());
  }

  @override
  void dispose() {
    _channelController.dispose();
    _nameController.dispose();
    _engine?.release();
    super.dispose();
  }

  bool _isScreenShareUid(int uid) => uid % 100 == 99;

  int _screenShareUidFor(int baseUid) {
    final candidate = baseUid * 100 + 99;
    if (candidate > 0xFFFFFFFF) {
      throw StateError('UID too large for screen share: $candidate');
    }
    return candidate;
  }

  bool get _isAnyScreenSharing => _isScreenSharing || _remoteScreenShareUid != null;

  void _reconcileFocusMode() {
    final anySharing = _isAnyScreenSharing;

    if (anySharing) {
      if (_focusMode != FocusMode.screen) {
        _focusModeBeforeScreenShare ??= _focusMode;
        _focusMode = FocusMode.screen;
      }
      return;
    }

    if (_focusMode == FocusMode.screen) {
      final previous = _focusModeBeforeScreenShare;
      _focusModeBeforeScreenShare = null;

      if (previous == FocusMode.whiteboard && _whiteboardUuid != null) {
        _focusMode = FocusMode.whiteboard;
      } else {
        _focusMode = FocusMode.none;
      }
    }
  }

  String _requiredEnv(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty) {
      throw StateError('Missing env var: $key');
    }
    return value;
  }

  Future<void> _ensurePermissions() async {
    if (kIsWeb) return;
    await [Permission.microphone, Permission.camera].request();
  }

  Future<RtcEngineEx> _createEngine() async {
    final appId = _requiredEnv('AGORA_APP_ID');

    final engine = createAgoraRtcEngineEx();
    await engine.initialize(RtcEngineContext(appId: appId));
    await engine.enableAudio();
    await engine.enableVideo();
    await engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          setState(() => _error = '[Agora] $err: $msg');
        },
        onJoinChannelSuccess: (connection, elapsed) {
          if (connection.localUid != _localUid) return;

          setState(() {
            _joined = true;
            _error = null;
            _userNames[_localUid] = _nameController.text.trim().isEmpty 
                ? 'Guest' 
                : _nameController.text.trim();
          });
        },
        onLeaveChannel: (connection, stats) {
          if (connection.localUid != _localUid) {
            if (connection.localUid == _screenShareUid) {
              setState(() {
                final shareUid = _screenShareUid;
                if (shareUid != null) {
                  _remoteUids.remove(shareUid);
                  if (_remoteScreenShareUid == shareUid) {
                    _remoteScreenShareUid = null;
                  }
                }
                _isScreenSharing = false;
                _screenShareUid = null;
                _reconcileFocusMode();
              });
            }
            return;
          }

          setState(() {
            _joined = false;
            _remoteUids.clear();
            _userNames.clear();
            _focusMode = FocusMode.none;
            _focusModeBeforeScreenShare = null;
            _whiteboardUuid = null;
            _whiteboardRoomToken = null;
            _isScreenSharing = false;
            _screenShareUid = null;
            _remoteScreenShareUid = null;
          });
        },
        onLocalVideoStateChanged: (source, state, reason) {
          if (source != VideoSourceType.videoSourceScreen &&
              source != VideoSourceType.videoSourceScreenPrimary) {
            return;
          }

          final isSharing = state == LocalVideoStreamState.localVideoStreamStateCapturing ||
              state == LocalVideoStreamState.localVideoStreamStateEncoding;
          setState(() {
            _isScreenSharing = isSharing;
            _reconcileFocusMode();
          });

          if (!isSharing && _screenShareUid != null && !_stoppingScreenShare) {
            _stopScreenShare(fromExternalStop: true);
          }

          if (state == LocalVideoStreamState.localVideoStreamStateFailed) {
            setState(() => _error = '[ScreenShare] failed: $reason');
          }
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          setState(() {
            if (remoteUid == _localUid || remoteUid == _screenShareUid) {
              return;
            }
            _remoteUids.add(remoteUid);
            if (_isScreenShareUid(remoteUid)) {
              _remoteScreenShareUid ??= remoteUid;
            }
            _reconcileFocusMode();
          });

          // Try to fetch this participant's info from the backend session with retry
          final channel = _currentChannel;
          if (channel.isNotEmpty) {
            _fetchRemoteUserWithRetry(channel, remoteUid);
          }
        },
        onUserOffline: (connection, remoteUid, reason) {
          setState(() {
            _remoteUids.remove(remoteUid);
            _userNames.remove(remoteUid);
            if (_remoteScreenShareUid == remoteUid) {
              _remoteScreenShareUid = null;
            }
            _reconcileFocusMode();
          });
        },
      ),
    );

    return engine;
  }

  int _pickUid() {
    final random = Random();
    while (true) {
      final uid = 100000 + random.nextInt(900000);
      if (!_isScreenShareUid(uid)) return uid;
    }
  }

  /// Fetch remote user info with retry logic (handles race condition when remote
  /// user hasn't finished registering with the backend yet).
  Future<void> _fetchRemoteUserWithRetry(String channel, int remoteUid, {int attempt = 0}) async {
    const maxAttempts = 5;
    const retryDelays = [500, 1000, 2000, 3000, 5000]; // ms

    try {
      final u = await _apiService.getSessionUser(
        channelName: channel,
        userId: remoteUid.toString(),
      );
      if (u != null && mounted) {
        setState(() {
          _sessionUsers[remoteUid.toString()] = u;
          _userNames[remoteUid] = u.displayName?.isNotEmpty == true
              ? u.displayName!
              : 'Remote ($remoteUid)';
        });
      } else if (attempt < maxAttempts - 1) {
        // User not found yet, retry after delay
        await Future.delayed(Duration(milliseconds: retryDelays[attempt]));
        if (mounted && _remoteUids.contains(remoteUid)) {
          _fetchRemoteUserWithRetry(channel, remoteUid, attempt: attempt + 1);
        }
      }
    } catch (_) {
      // On error, retry if attempts remain
      if (attempt < maxAttempts - 1 && mounted && _remoteUids.contains(remoteUid)) {
        await Future.delayed(Duration(milliseconds: retryDelays[attempt]));
        _fetchRemoteUserWithRetry(channel, remoteUid, attempt: attempt + 1);
      }
    }
  }

  Future<void> _join() async {
    if (_joined || _loading) return;

    final channelName = _channelController.text.trim();
    if (channelName.isEmpty) {
      setState(() => _error = 'Insira o nome do canal.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _focusMode = FocusMode.none;
      _whiteboardUuid = null;
      _whiteboardRoomToken = null;
    });

    try {
      await _ensurePermissions();

      final uid = _pickUid();
      final tokenResponse = await _apiService.fetchRtcToken(
        channelName: channelName,
        uid: uid.toString(),
      );

      final engine = _engine ?? await _createEngine();
      _engine = engine;
      _currentChannel = channelName;
      _localUid = uid;
      _screenShareUid = null;
      _userNames.clear();

      final displayName = _nameController.text.trim().isEmpty ? 'Guest' : _nameController.text.trim();
      _userNames[uid] = displayName;

      try {
        await engine.registerLocalUserAccount(appId: _requiredEnv('AGORA_APP_ID'), userAccount: displayName);
      } catch (_) {
        // ignore
      }

      await engine.startPreview();
      await engine.joinChannelEx(
        token: tokenResponse.token,
        connection: RtcConnection(channelId: channelName, localUid: uid),
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      // Register this user with the backend session (so other clients can read the display name)
      try {
        final session = await _apiService.joinOrCreateSession(
          channelName: _currentChannel,
          userId: uid.toString(),
          displayName: displayName,
        );

        // Populate local caches: session users and name map
        for (final u in session.users) {
          _sessionUsers[u.userId] = u;
          // if the userId is a numeric uid, map it to the integer uid for display
          final int? maybeUid = int.tryParse(u.userId);
          if (maybeUid != null) {
            _userNames[maybeUid] = u.displayName ?? 'Remote ($maybeUid)';
          }
        }
      } catch (_) {
        // ignore errors contacting the backend
      }

      // Register video call in database (for call history and duration tracking)
      try {
        if (widget.isHost) {
          // Host starts/creates the call
          await _apiService.startVideoCall(
            channelName: _currentChannel,
            username: displayName,
            displayName: displayName,
            callType: 'video',
          );
        } else {
          // Participant joins existing call (must exist)
          await _apiService.joinVideoCall(
            channelName: _currentChannel,
            username: displayName,
            displayName: displayName,
          );
        }
      } catch (e) {
        if (e is NoActiveCallException) {
          // No active call - participant cannot join
          setState(() {
            _error = e.message;
            _loading = false;
          });
          // Leave the Agora channel since we can't register the call
          try {
            await _engine?.leaveChannelEx(
              connection: RtcConnection(channelId: _currentChannel, localUid: _localUid),
              options: const LeaveChannelOptions(),
            );
          } catch (_) {}
          return;
        }
        // Log but don't fail the call if video call registration fails
        debugPrint('Failed to register video call: $e');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _leave() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // Get username before clearing state
    final displayName = _nameController.text.trim().isEmpty ? 'Guest' : _nameController.text.trim();
    final channelToLeave = _currentChannel;

    try {
      if (_engine != null) {
        if (_screenShareUid != null) {
          try {
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
              connection: RtcConnection(channelId: _currentChannel, localUid: _screenShareUid!),
            );
          } catch (_) {}

          try {
            await _engine!.leaveChannelEx(
              connection: RtcConnection(channelId: _currentChannel, localUid: _screenShareUid!),
              options: const LeaveChannelOptions(),
            );
          } catch (_) {}
        }

        try {
          await _engine!.stopScreenCapture();
        } catch (_) {}

        await _engine!.leaveChannelEx(
          connection: RtcConnection(channelId: _currentChannel, localUid: _localUid),
          options: const LeaveChannelOptions(),
        );
      }

      // Register leaving the video call in database (to track participant duration)
      if (channelToLeave.isNotEmpty) {
        try {
          final leaveResponse = await _apiService.leaveVideoCall(
            channelName: channelToLeave,
            username: displayName,
          );
          debugPrint('Left video call. Duration: ${leaveResponse.participant.durationSeconds}s');
        } catch (e) {
          // Log but don't fail if leave registration fails
          debugPrint('Failed to register leaving video call: $e');
        }
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _startScreenShare() async {
    if (!_joined || _engine == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final channelName = _currentChannel.isNotEmpty ? _currentChannel : _channelController.text.trim();

      final shareUid = _screenShareUid ?? _screenShareUidFor(_localUid);
      _screenShareUid = shareUid;

      final tokenResponse = await _apiService.fetchRtcToken(
        channelName: channelName,
        uid: shareUid.toString(),
      );

      await _engine!.joinChannelEx(
        token: tokenResponse.token,
        connection: RtcConnection(channelId: channelName, localUid: shareUid),
        options: const ChannelMediaOptions(
          autoSubscribeAudio: false,
          autoSubscribeVideo: false,
          publishScreenTrack: true,
          publishSecondaryScreenTrack: true,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          publishScreenCaptureAudio: true,
          publishScreenCaptureVideo: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );

      await _engine!.startScreenCapture(
        const ScreenCaptureParameters2(captureAudio: true, captureVideo: true),
      );

      await _engine!.startPreview(sourceType: VideoSourceType.videoSourceScreen);

      await _engine!.updateChannelMediaOptionsEx(
        options: const ChannelMediaOptions(
          publishScreenTrack: true,
          publishSecondaryScreenTrack: true,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          publishScreenCaptureAudio: true,
          publishScreenCaptureVideo: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
        connection: RtcConnection(channelId: channelName, localUid: shareUid),
      );

      setState(() {
        _reconcileFocusMode();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _stopScreenShare({bool fromExternalStop = false}) async {
    if (_engine == null) return;

    if (_stoppingScreenShare) return;
    _stoppingScreenShare = true;

    if (!fromExternalStop) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final shareUid = _screenShareUid;
      if (shareUid != null) {
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
          connection: RtcConnection(channelId: _currentChannel, localUid: shareUid),
        );
      }

      try {
        await _engine!.stopScreenCapture();
      } catch (_) {}

      if (shareUid != null) {
        await _engine!.leaveChannelEx(
          connection: RtcConnection(channelId: _currentChannel, localUid: shareUid),
          options: const LeaveChannelOptions(),
        );
      }

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
          connection: RtcConnection(channelId: _currentChannel, localUid: _localUid),
        );
      } catch (_) {}

      try {
        await _engine!.enableLocalVideo(true);
        await _engine!.startPreview();
      } catch (_) {}

      setState(() {
        if (shareUid != null) {
          _remoteUids.remove(shareUid);
          if (_remoteScreenShareUid == shareUid) {
            _remoteScreenShareUid = null;
          }
        }
        _isScreenSharing = false;
        _screenShareUid = null;
        _reconcileFocusMode();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      _stoppingScreenShare = false;
      if (!fromExternalStop) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openWhiteboard() async {
    if (!_joined) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // First check if we have hardcoded values in .env
      final envUuid = dotenv.env['WHITEBOARD_UUID']?.trim();
      final envRoomToken = dotenv.env['WHITEBOARD_ROOM_TOKEN']?.trim();
      
      if (envUuid?.isNotEmpty == true && envRoomToken?.isNotEmpty == true) {
        // Use hardcoded values
        setState(() {
          _whiteboardUuid = envUuid;
          _whiteboardRoomToken = envRoomToken;
          _focusMode = FocusMode.whiteboard;
          _reconcileFocusMode();
        });
      } else {
        // Fetch from API
        final response = await _apiService.fetchWhiteboardToken(
          channelName: _currentChannel.isNotEmpty ? _currentChannel : _channelController.text.trim(),
          uid: _localUid,
        );

        setState(() {
          _whiteboardUuid = response.uuid;
          _whiteboardRoomToken = response.token;
          _focusMode = FocusMode.whiteboard;
          _reconcileFocusMode();
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _closeWhiteboard() {
    setState(() {
      _focusMode = FocusMode.none;
      _whiteboardUuid = null;
      _whiteboardRoomToken = null;
      _reconcileFocusMode();
    });
  }

  Future<void> _toggleMute() async {
    if (_engine == null) return;
    setState(() {
      _isMuted = !_isMuted;
    });

    // Update local audio state in Agora engine
    _engine!.muteLocalAudioStream(_isMuted);

    // Inform backend about the change so session state reflects mute flags
    try {
      final resp = await _apiService.setUserAudioMute(channelName: _currentChannel, userId: _localUid.toString(), muted: _isMuted);
      // update cached session user
      _sessionUsers[_localUid.toString()] = SessionUser(
        userId: _localUid.toString(),
        isAudioMuted: _isMuted,
        isVideoMuted: _sessionUsers[_localUid.toString()]?.isVideoMuted ?? false,
        joinedAt: _sessionUsers[_localUid.toString()]?.joinedAt,
      );
    } catch (_) {
      // ignore errors from reporting to backend for now
    }
  }

  Future<void> _toggleVideo() async {
    if (_engine == null) return;
    setState(() {
      _isVideoOff = !_isVideoOff;
    });

    // Update local video state in Agora engine
    _engine!.muteLocalVideoStream(_isVideoOff);

    // Inform backend about the change so session state reflects mute flags
    try {
      final resp = await _apiService.setUserVideoMute(channelName: _currentChannel, userId: _localUid.toString(), muted: _isVideoOff);
      _sessionUsers[_localUid.toString()] = SessionUser(
        userId: _localUid.toString(),
        isAudioMuted: _sessionUsers[_localUid.toString()]?.isAudioMuted ?? _isMuted,
        isVideoMuted: _isVideoOff,
        joinedAt: _sessionUsers[_localUid.toString()]?.joinedAt,
      );
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    final remoteScreenUid = _remoteScreenShareUid;
    final mainConnection = RtcConnection(channelId: _currentChannel, localUid: _localUid);

    // Build video tiles
    final tiles = <Widget>[
      _VideoTile(
        label: Row(children: [
          Text(_joined ? (_userNames[_localUid] ?? 'Local ($_localUid)') : 'Local'),
          const SizedBox(width: 8),
          if (_isMuted) const Icon(Icons.mic_off, size: 12, color: Colors.white70),
          if (_isVideoOff) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.videocam_off, size: 12, color: Colors.white70)),
        ]),
        child: _engine == null
            ? const _PlaceholderTile()
            : AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
      ),
      for (final uid in _remoteUids)
        if (uid != remoteScreenUid)
          _VideoTile(
            label: Builder(builder: (ctx) {
              final sessionUser = _sessionUsers[uid.toString()];
              final isAudioMuted = sessionUser?.isAudioMuted ?? false;
              final isVideoMuted = sessionUser?.isVideoMuted ?? false;
              return Row(children: [
                Text(_userNames[uid] ?? 'Remote ($uid)'),
                const SizedBox(width: 8),
                if (isAudioMuted)
                  const Icon(Icons.mic_off, size: 12, color: Colors.white70),
                if (isVideoMuted)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.videocam_off, size: 12, color: Colors.white70),
                  ),
              ]);
            }),
            child: _engine == null
                ? const _PlaceholderTile()
                : AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: _engine!,
                      canvas: VideoCanvas(uid: uid),
                      connection: mainConnection,
                    ),
                  ),
          ),
    ];

    Widget content;
    if (_focusMode == FocusMode.none) {
      // Grid view of all participants
      content = GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: isWide ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isWide ? 16 / 9 : 4 / 3,
        children: tiles,
      );
    } else {
      // Focus mode: center stage + sidebar
      final centerStage = _focusMode == FocusMode.whiteboard && _whiteboardUuid != null && _whiteboardRoomToken != null
          ? WhiteboardPanel(
              appIdentifier: dotenv.env['WHITEBOARD_APP_IDENTIFIER'] ?? '',
              region: dotenv.env['WHITEBOARD_REGION'] ?? 'us-sv',
              uuid: _whiteboardUuid!,
              roomToken: _whiteboardRoomToken!,
              uid: _localUid,
            )
          : (_focusMode == FocusMode.screen && _engine != null)
              ? (_isScreenSharing
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: _engine!,
                        canvas: const VideoCanvas(
                          uid: 0,
                          sourceType: VideoSourceType.videoSourceScreen,
                          renderMode: RenderModeType.renderModeFit,
                        ),
                      ),
                    )
                  : (remoteScreenUid != null)
                      ? AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: _engine!,
                            canvas: VideoCanvas(
                              uid: remoteScreenUid,
                              renderMode: RenderModeType.renderModeFit,
                            ),
                            connection: mainConnection,
                          ),
                        )
                      : const _CenterStagePlaceholder(label: 'No screen share'))
              : const _CenterStagePlaceholder(label: 'No screen share');

      content = Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(12), child: centerStage)),
            const SizedBox(width: 16),
            SizedBox(
              width: 300,
              child: ListView.separated(
                itemCount: tiles.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) => AspectRatio(
                  aspectRatio: 16 / 9,
                  child: tiles[index],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final openWhiteboardEnabled = !_loading && _joined;
    final isWhiteboardOpen = _focusMode == FocusMode.whiteboard;
    final isScreenSharing = _isScreenSharing;

    return Scaffold(
      body: Column(
        children: [
          // Header bar
          _HeaderBar(
            channelController: _channelController,
            nameController: _nameController,
            loading: _loading,
            joined: _joined,
            onLeave: _loading || !_joined ? null : _leave,
            onShareScreen: _loading || !_joined || _isScreenSharing || _remoteScreenShareUid != null ? null : _startScreenShare,
            onStopScreen: _loading || !_joined || !_isScreenSharing ? null : _stopScreenShare,
            onOpenWhiteboard: !openWhiteboardEnabled ? null : _openWhiteboard,
            onCloseWhiteboard: !openWhiteboardEnabled ? null : _closeWhiteboard,
            isWhiteboardOpen: isWhiteboardOpen,
            isScreenSharing: isScreenSharing,
            isMuted: _isMuted,
            isVideoOff: _isVideoOff,
            onToggleMute: _joined ? () => _toggleMute() : null,
            onToggleVideo: _joined ? () => _toggleVideo() : null,
            isChatOpen: _isChatOpen,
            onToggleChat: _joined ? () => setState(() => _isChatOpen = !_isChatOpen) : null,
          ),
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.withOpacity(0.2),
              child: Text(_error!, style: const TextStyle(color: Colors.white)),
            ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: content),
                // Chat panel
                if (_isChatOpen && _joined)
                  ChatPanel(
                    channelName: _currentChannel,
                    userId: widget.userName, // Use actual username for API calls, not Agora UID
                    displayName: _nameController.text.trim().isEmpty ? 'Guest' : _nameController.text.trim(),
                    onClose: () => setState(() => _isChatOpen = false),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.channelController,
    required this.nameController,
    required this.loading,
    required this.joined,
    required this.onLeave,
    required this.onShareScreen,
    required this.onStopScreen,
    required this.onOpenWhiteboard,
    required this.onCloseWhiteboard,
    required this.isWhiteboardOpen,
    required this.isScreenSharing,
    required this.isMuted,
    required this.isVideoOff,
    required this.onToggleMute,
    required this.onToggleVideo,
    required this.isChatOpen,
    required this.onToggleChat,
  });

  final TextEditingController channelController;
  final TextEditingController nameController;
  final bool loading;
  final bool joined;
  final VoidCallback? onLeave;
  final VoidCallback? onShareScreen;
  final VoidCallback? onStopScreen;
  final VoidCallback? onOpenWhiteboard;
  final VoidCallback? onCloseWhiteboard;
  final bool isWhiteboardOpen;
  final bool isScreenSharing;
  final bool isMuted;
  final bool isVideoOff;
  final VoidCallback? onToggleMute;
  final VoidCallback? onToggleVideo;
  final bool isChatOpen;
  final VoidCallback? onToggleChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(bottom: BorderSide(color: Color(0xFF2B2B2B))),
      ),
      child: Row(
        children: [
          // Channel info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tag, size: 16, color: Colors.white54),
                const SizedBox(width: 6),
                Text(
                  channelController.text,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.person, size: 16, color: Colors.white54),
                const SizedBox(width: 6),
                Text(
                  nameController.text,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Audio/Video controls
          IconButton(
            icon: Icon(isMuted ? Icons.mic_off : Icons.mic),
            color: isMuted ? Colors.red : Colors.white,
            onPressed: onToggleMute,
            tooltip: isMuted ? 'Unmute' : 'Mute',
          ),
          IconButton(
            icon: Icon(isVideoOff ? Icons.videocam_off : Icons.videocam),
            color: isVideoOff ? Colors.red : Colors.white,
            onPressed: onToggleVideo,
            tooltip: isVideoOff ? 'Turn on camera' : 'Turn off camera',
          ),
          const SizedBox(width: 8),
          
          // Screen share
          if (isScreenSharing)
            _ActionButton(label: 'Stop screen', onPressed: onStopScreen, icon: Icons.stop_screen_share)
          else
            _ActionButton(label: 'Share screen', onPressed: onShareScreen, icon: Icons.screen_share),
          const SizedBox(width: 8),
          
          // Whiteboard
          if (isWhiteboardOpen)
            _ActionButton(label: 'Close whiteboard', onPressed: onCloseWhiteboard, icon: Icons.edit_off)
          else
            _ActionButton(label: 'Open whiteboard', onPressed: onOpenWhiteboard, icon: Icons.edit),
          const SizedBox(width: 8),
          
          // Chat
          _ActionButton(
            label: isChatOpen ? 'Close chat' : 'Open chat',
            onPressed: onToggleChat,
            icon: isChatOpen ? Icons.chat_bubble : Icons.chat_bubble_outline,
          ),
          
          const Spacer(),
          
          // Loading indicator
          if (loading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          
          // Leave button
          FilledButton.tonal(
            onPressed: onLeave,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.call_end, size: 18),
                SizedBox(width: 8),
                Text('Leave'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed, required this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.label, required this.child});

  final Widget label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF222222)),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              left: 8,
              bottom: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: DefaultTextStyle(style: const TextStyle(fontSize: 12), child: label),
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
      child: Text('Not connected', style: TextStyle(color: Colors.white54)),
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
        child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 16)),
      ),
    );
  }
}
