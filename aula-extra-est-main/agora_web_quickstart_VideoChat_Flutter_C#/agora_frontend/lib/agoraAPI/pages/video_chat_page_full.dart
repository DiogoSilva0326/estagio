import 'dart:math';
import 'dart:convert';
import 'dart:typed_data';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import 'dart:html' as html show Blob, Url, AnchorElement, IFrameElement, document, HttpRequest;

import '../services/token_service.dart';
import '../widgets/whiteboard_panel.dart';

enum FocusMode { none, screen, whiteboard }

class _ChatMessage {
  final int fromUid;
  final String fromName;
  final int? toUid;
  final String? toName;
  final String text;
  final DateTime timestamp;

  _ChatMessage({
    required this.fromUid,
    required this.fromName,
    required this.text,
    required this.timestamp,
    this.toUid,
    this.toName,
  });
}

class _FileMessage extends _ChatMessage {
  final String fileName;
  final String mimeType;
  final Uint8List bytes;
  final String? url;
  final int? size;
  
  _FileMessage({
    required int fromUid,
    required String fromName,
    required DateTime timestamp,
    required this.fileName,
    required this.mimeType,
    required this.bytes,
    this.url,
    this.size,
    int? toUid,
    String? toName,
  }) : super(
    fromUid: fromUid,
    fromName: fromName,
    text: '[Arquivo: $fileName]',
    timestamp: timestamp,
    toUid: toUid,
    toName: toName,
  );
}

class VideoChatPage extends StatefulWidget {
  final String channelName;
  final String userName;

  const VideoChatPage({
    super.key,
    required this.channelName,
    required this.userName,
  });

  @override
  State<VideoChatPage> createState() => _VideoChatPageState();
}

class _VideoChatPageState extends State<VideoChatPage> {
  final _tokenService = TokenService();
  final _remoteUids = <int>{};
  final _userNames = <int, String>{};
  final _messages = <_ChatMessage>[];

  late final TextEditingController _channelController;
  late final TextEditingController _nameController;
  late final TextEditingController _chatController;
  late final TextEditingController _recipientController;

  RtcEngineEx? _engine;
  String _currentChannel = '';
  int _localUid = 0;
  int? _screenShareUid;
  int? _remoteScreenShareUid;
  bool _joined = false;
  bool _chatOpen = false;

  bool _isScreenSharing = false;
  bool _stoppingScreenShare = false;
  int? _dataStreamId;

  FocusMode? _focusModeBeforeScreenShare;

  FocusMode _focusMode = FocusMode.none;
  WhiteboardToken? _whiteboardToken;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _channelController = TextEditingController(text: widget.channelName);
    _nameController = TextEditingController(text: widget.userName);
    _chatController = TextEditingController();
    _recipientController = TextEditingController();
  }

  @override
  void dispose() {
    _channelController.dispose();
    _nameController.dispose();
    _chatController.dispose();
    _recipientController.dispose();
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

      if (previous == FocusMode.whiteboard && _whiteboardToken != null) {
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
        onJoinChannelSuccess: (connection, elapsed) async {
          if (connection.localUid != _localUid) return;

          setState(() {
            _joined = true;
            _error = null;
            _userNames[_localUid] = _effectiveDisplayName();
          });

          await _createStreamAndBroadcastName();
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
            _messages.clear();
            _focusMode = FocusMode.none;
            _focusModeBeforeScreenShare = null;
            _whiteboardToken = null;
            _isScreenSharing = false;
            _screenShareUid = null;
            _remoteScreenShareUid = null;
            _dataStreamId = null;
            _chatOpen = false;
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

          _broadcastNameRepeated(times: 2);
          _ensureRemoteName(remoteUid);
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

        onUserInfoUpdated: (uid, info) {
          final account = info.userAccount;
          if (account != null && account.isNotEmpty) {
            setState(() {
              _userNames[uid] = account;
            });
          }
        },

        onStreamMessage: (connection, remoteUid, streamId, data, length, sentTs) {
          try {
            final message = String.fromCharCodes(data);
            final decoded = jsonDecode(message);
            if (decoded is Map) {
              if (decoded['type'] == 'name' && decoded['name'] is String) {
                setState(() {
                  _userNames[remoteUid] = decoded['name'] as String;
                });
              } else if (decoded['type'] == 'chat' && decoded['text'] is String) {
                final toUid = decoded['toUid'] is int ? decoded['toUid'] as int : null;
                final toName = decoded['toName'] is String ? decoded['toName'] as String : null;
                final matchesMe = toUid == null && toName == null
                    ? true
                    : (toUid != null && toUid == _localUid) ||
                        (toName != null && toName == (_userNames[_localUid] ?? _effectiveDisplayName()));
                if (matchesMe || remoteUid == _localUid) {
                  setState(() {
                    _messages.add(
                      _ChatMessage(
                        fromUid: remoteUid,
                        fromName: _userNames[remoteUid] ?? 'User $remoteUid',
                        toUid: toUid,
                        toName: toName,
                        text: decoded['text'] as String,
                        timestamp: DateTime.now(),
                      ),
                    );
                  });
                }
              } else if (decoded['type'] == 'file' && decoded['data'] is String) {
                try {
                  final bytes = base64Decode(decoded['data'] as String);
                  final fileName = decoded['fileName'] as String? ?? 'arquivo';
                  final toUid = decoded['toUid'] is int ? decoded['toUid'] as int : null;
                  final toName = decoded['toName'] is String ? decoded['toName'] as String : null;
                  final matchesMe = toUid == null && toName == null
                      ? true
                      : (toUid != null && toUid == _localUid) ||
                          (toName != null && toName == (_userNames[_localUid] ?? _effectiveDisplayName()));
                  if (matchesMe || remoteUid == _localUid) {
                    setState(() {
                      _messages.add(
                        _FileMessage(
                          fromUid: remoteUid,
                          fromName: _userNames[remoteUid] ?? 'User $remoteUid',
                          timestamp: DateTime.now(),
                          fileName: fileName,
                          mimeType: decoded['mimeType'] as String? ?? 'application/octet-stream',
                          bytes: bytes,
                          toUid: toUid,
                          toName: toName,
                        ),
                      );
                    });
                  }
                } catch (_) {
                  // ignore malformed file messages
                }
              } else if (decoded['type'] == 'file-link' && decoded['url'] is String) {
                final toUid = decoded['toUid'] is int ? decoded['toUid'] as int : null;
                final toName = decoded['toName'] is String ? decoded['toName'] as String : null;
                final matchesMe = toUid == null && toName == null
                    ? true
                    : (toUid != null && toUid == _localUid) ||
                        (toName != null && toName == (_userNames[_localUid] ?? _effectiveDisplayName()));
                if (matchesMe || remoteUid == _localUid) {
                  setState(() {
                    _messages.add(
                      _FileMessage(
                        fromUid: remoteUid,
                        fromName: _userNames[remoteUid] ?? 'User $remoteUid',
                        timestamp: DateTime.now(),
                        fileName: (decoded['fileName'] as String?) ?? 'arquivo',
                        mimeType: (decoded['mimeType'] as String?) ?? 'application/octet-stream',
                        bytes: Uint8List(0),
                        url: decoded['url'] as String,
                        size: decoded['size'] is int ? decoded['size'] as int : null,
                        toUid: toUid,
                        toName: toName,
                      ),
                    );
                  });
                }
              }
            }
          } catch (_) {
            // ignore malformed messages
          }
        },
      ),
    );

    return engine;
  }

  RtcConnection get _mainConnection => RtcConnection(channelId: _currentChannel, localUid: _localUid);

  Future<void> _refreshUserInfo(int uid) async {
    if (_engine == null || !_joined) return;
    try {
      final info = await _engine!.getUserInfoByUid(uid);
      final account = info.userAccount;
      if (account != null && account.isNotEmpty) {
        setState(() {
          _userNames[uid] = account;
        });
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _ensureRemoteName(int uid, {int attempts = 3, Duration interval = const Duration(milliseconds: 700)}) async {
    for (var i = 0; i < attempts; i++) {
      if (_userNames.containsKey(uid) || !_joined) return;
      await _refreshUserInfo(uid);
      if (_userNames.containsKey(uid) || !_joined) return;
      if (i < attempts - 1) {
        await Future.delayed(interval);
      }
    }
  }

  String _effectiveDisplayName() {
    final name = _nameController.text.trim();
    return name.isEmpty ? 'Guest' : name;
  }

  Future<void> _createStreamAndBroadcastName() async {
    if (_engine == null || !_joined || _currentChannel.isEmpty) return;
    if (_dataStreamId == null) {
      try {
        _dataStreamId = await _engine!.createDataStreamEx(
          config: const DataStreamConfig(syncWithAudio: false, ordered: true),
          connection: _mainConnection,
        );
      } catch (_) {
        try {
          _dataStreamId = await _engine!.createDataStream(
            const DataStreamConfig(syncWithAudio: false, ordered: true),
          );
        } catch (_) {}
      }
    }

    final streamId = _dataStreamId;
    if (streamId == null) return;

    final payload = jsonEncode({'type': 'name', 'name': _effectiveDisplayName()});
    final bytes = Uint8List.fromList(payload.codeUnits);

    try {
      await _engine!.sendStreamMessageEx(
        streamId: streamId,
        data: bytes,
        length: bytes.length,
        connection: _mainConnection,
      );
    } catch (_) {
      try {
        await _engine!.sendStreamMessage(
          streamId: streamId,
          data: bytes,
          length: bytes.length,
        );
      } catch (_) {}
    }
  }

  Future<void> _sendChatMessage() async {
    if (_engine == null || !_joined) return;
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    int? toUid;
    String? toName;
    final recipient = _recipientController.text.trim();
    if (recipient.isNotEmpty) {
      final asInt = int.tryParse(recipient);
      if (asInt != null) {
        toUid = asInt;
      } else {
        // Try resolve by name
        final match = _userNames.entries.firstWhere(
          (e) => e.value.toLowerCase() == recipient.toLowerCase(),
          orElse: () => const MapEntry(-1, ''),
        );
        if (match.key != -1) {
          toUid = match.key;
        } else {
          toName = recipient; // fallback to name match on receiver
        }
      }
    }

    final payload = jsonEncode({
      'type': 'chat',
      'text': text,
      if (toUid != null) 'toUid': toUid,
      if (toName != null) 'toName': toName,
      'fromUid': _localUid,
      'fromName': _userNames[_localUid] ?? _effectiveDisplayName(),
    });

    final bytes = Uint8List.fromList(payload.codeUnits);
    final streamId = _dataStreamId ??
        await _engine!.createDataStreamEx(
          config: const DataStreamConfig(syncWithAudio: false, ordered: true),
          connection: _mainConnection,
        );
    _dataStreamId = streamId;

    try {
      await _engine!.sendStreamMessageEx(
        streamId: streamId,
        data: bytes,
        length: bytes.length,
        connection: _mainConnection,
      );
    } catch (_) {
      try {
        await _engine!.sendStreamMessage(streamId: streamId, data: bytes, length: bytes.length);
      } catch (_) {}
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          fromUid: _localUid,
          fromName: _userNames[_localUid] ?? _effectiveDisplayName(),
          toUid: toUid,
          toName: toName,
          text: text,
          timestamp: DateTime.now(),
        ),
      );
      _chatController.clear();
    });
  }

  Future<void> _broadcastNameRepeated({int times = 3, Duration interval = const Duration(seconds: 1)}) async {
    for (var i = 0; i < times; i++) {
      if (!_joined) break;
      await _createStreamAndBroadcastName();
      if (i < times - 1) {
        await Future.delayed(interval);
      }
    }
  }

  int _pickUid() {
    final random = Random();
    while (true) {
      final uid = 100000 + random.nextInt(900000);
      if (!_isScreenShareUid(uid)) return uid;
    }
  }

  Future<void> _join() async {
    if (_joined || _loading) {
      setState(() => _error = 'Já está na chamada.');
      return;
    }

    final channelName = _channelController.text.trim();
    if (channelName.isEmpty) {
      setState(() => _error = 'Insira o nome do canal.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _focusMode = FocusMode.none;
      _whiteboardToken = null;
    });

    try {
      await _ensurePermissions();

      final uid = _pickUid();
      final token = await _tokenService.fetchRtcToken(uid: uid, channelName: channelName);

      final engine = _engine ?? await _createEngine();
      _engine = engine;
      _currentChannel = channelName;
      _localUid = uid;
      _screenShareUid = null;
      _userNames.clear();

      try {
        await engine.registerLocalUserAccount(appId: _requiredEnv('AGORA_APP_ID'), userAccount: _effectiveDisplayName());
      } catch (_) {
        // ignore
      }

      _userNames[uid] = _effectiveDisplayName();

      await engine.startPreview();
      await engine.joinChannelEx(
        token: token,
        connection: RtcConnection(channelId: channelName, localUid: uid),
        options: const ChannelMediaOptions(
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
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
          } catch (_) {
            // ignore
          }

          try {
            await _engine!.leaveChannelEx(
              connection: RtcConnection(channelId: _currentChannel, localUid: _screenShareUid!),
              options: const LeaveChannelOptions(),
            );
          } catch (_) {
            // ignore
          }
        }

        try {
          await _engine!.stopScreenCapture();
        } catch (_) {
          // ignore
        }

        await _engine!.leaveChannelEx(
          connection: RtcConnection(channelId: _currentChannel, localUid: _localUid),
          options: const LeaveChannelOptions(),
        );
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

      final shareToken = await _tokenService.fetchRtcToken(uid: shareUid, channelName: channelName);

      await _engine!.joinChannelEx(
        token: shareToken,
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
      } catch (_) {
        // ignore
      }

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
      } catch (_) {
        // ignore
      }

      try {
        await _engine!.enableLocalVideo(true);
      } catch (_) {
        // ignore
      }

      try {
        await _engine!.startPreview();
      } catch (_) {
        // ignore
      }

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
      final envUuid = dotenv.env['WHITEBOARD_UUID']?.trim();
      final envRoomToken = dotenv.env['WHITEBOARD_ROOM_TOKEN']?.trim();
      final forceEnv = (dotenv.env['WHITEBOARD_FORCE_ENV'] ?? '').toLowerCase() == 'true';

      final token = (forceEnv && envUuid?.isNotEmpty == true && envRoomToken?.isNotEmpty == true)
          ? WhiteboardToken(uuid: envUuid!, roomToken: envRoomToken!)
          : await _tokenService.fetchWhiteboardToken(
              uid: _localUid,
              channelName: _currentChannel.isNotEmpty ? _currentChannel : _channelController.text.trim(),
            );

      setState(() {
        _whiteboardToken = token;
        _focusMode = FocusMode.whiteboard;
        _reconcileFocusMode();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _closeWhiteboard() {
    setState(() {
      _focusMode = FocusMode.none;
      _whiteboardToken = null;
      _reconcileFocusMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;

    final remoteScreenUid = _remoteScreenShareUid;
    final mainConnection = RtcConnection(channelId: _currentChannel, localUid: _localUid);

    final tiles = <Widget>[
      _VideoTile(
        label: _joined ? (_userNames[_localUid] ?? 'Local ($_localUid)') : 'Local',
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
          label: _userNames[uid] ?? 'Remote ($uid)',
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
      content = GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: isWide ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isWide ? 16 / 9 : 4 / 3,
        children: tiles,
      );
    } else {
      final centerStage = _focusMode == FocusMode.whiteboard && _whiteboardToken != null
          ? WhiteboardPanel(
              appIdentifier: _requiredEnv('WHITEBOARD_APP_IDENTIFIER'),
              region: dotenv.env['WHITEBOARD_REGION']?.trim().isNotEmpty == true
                  ? dotenv.env['WHITEBOARD_REGION']!.trim()
                  : 'us-sv',
              uuid: _whiteboardToken!.uuid,
              roomToken: _whiteboardToken!.roomToken,
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
          _HeaderBar(
            channelController: _channelController,
            nameController: _nameController,
            loading: _loading,
            joined: _joined,
            onJoin: _loading || _joined ? null : _join,
            onLeave: _loading || !_joined ? null : _leave,
            onShareScreen:
                _loading || !_joined || _isScreenSharing || _remoteScreenShareUid != null ? null : _startScreenShare,
            onStopScreen: _loading || !_joined || !_isScreenSharing ? null : _stopScreenShare,
            onOpenWhiteboard: !openWhiteboardEnabled ? null : _openWhiteboard,
            onCloseWhiteboard: !openWhiteboardEnabled ? null : _closeWhiteboard,
            isWhiteboardOpen: isWhiteboardOpen,
            isScreenSharing: isScreenSharing,
            chatOpen: _chatOpen,
            onToggleChat: _joined
                ? () => setState(() {
                      _chatOpen = !_chatOpen;
                    })
                : null,
          ),
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.withValues(alpha: 0.2),
              child: Text(_error!, style: const TextStyle(color: Colors.white)),
            ),
          Expanded(
            child: Row(
              children: [
                Expanded(child: content),
                if (_chatOpen)
                  Container(
                    width: 320,
                    decoration: const BoxDecoration(
                      color: Color(0xFF101010),
                      border: Border(left: BorderSide(color: Color(0xFF2B2B2B))),
                    ),
                    child: _buildChatPanel(),
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
    required this.onJoin,
    required this.onLeave,
    required this.onShareScreen,
    required this.onStopScreen,
    required this.onOpenWhiteboard,
    required this.onCloseWhiteboard,
    required this.isWhiteboardOpen,
    required this.isScreenSharing,
    required this.chatOpen,
    required this.onToggleChat,
  });

  final TextEditingController channelController;
  final TextEditingController nameController;
  final bool loading;
  final bool joined;
  final VoidCallback? onJoin;
  final VoidCallback? onLeave;
  final VoidCallback? onShareScreen;
  final VoidCallback? onStopScreen;
  final VoidCallback? onOpenWhiteboard;
  final VoidCallback? onCloseWhiteboard;
  final bool isWhiteboardOpen;
  final bool isScreenSharing;
  final bool chatOpen;
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
          SizedBox(
            width: 260,
            child: TextField(
              controller: channelController,
              enabled: !loading && !joined,
              decoration: const InputDecoration(
                hintText: 'Channel name',
                isDense: true,
                filled: true,
                fillColor: Color(0xFF101010),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 200,
            child: TextField(
              controller: nameController,
              enabled: !loading && !joined,
              decoration: const InputDecoration(
                hintText: 'Seu nome',
                isDense: true,
                filled: true,
                fillColor: Color(0xFF101010),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _ActionButton(label: 'Join', onPressed: onJoin),
          const SizedBox(width: 8),
          _ActionButton(label: 'Leave', onPressed: onLeave),
          const SizedBox(width: 8),
          if (isScreenSharing)
            _ActionButton(label: 'Stop screen', onPressed: onStopScreen)
          else
            _ActionButton(label: 'Share screen', onPressed: onShareScreen),
          const SizedBox(width: 8),
          if (isWhiteboardOpen)
            _ActionButton(label: 'Close whiteboard', onPressed: onCloseWhiteboard)
          else
            _ActionButton(label: 'Open whiteboard', onPressed: onOpenWhiteboard),
          const SizedBox(width: 8),
          _ActionButton(label: chatOpen ? 'Close chat' : 'Open chat', onPressed: onToggleChat),
          const Spacer(),
          if (loading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

extension on _VideoChatPageState {
  Widget _chatMessageTile({
    required _ChatMessage m,
    required bool isMe,
  }) {
    final toLabel = (m.toUid != null)
        ? '#${m.toUid}'
        : (m.toName != null ? '@${m.toName}' : 'all');
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueGrey.shade700 : Colors.grey.shade800,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              '${m.fromName} → $toLabel',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
            const SizedBox(height: 2),
            Text(m.text),
          ],
        ),
      ),
    );
  }

  Widget _buildChatPanel() {
    return Column(
      children: [
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFF2B2B2B))),
          ),
          child: const Text('Chat', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final m = _messages[index];
              if (m is _FileMessage) {
                return _fileMessageTile(context, m);
              }
              final isMe = m.fromUid == _localUid;
              return _chatMessageTile(m: m, isMe: isMe);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        hintText: 'UID ou nome',
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFF141414),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      decoration: const InputDecoration(
                        hintText: 'Mensagem…',
                        isDense: true,
                        filled: true,
                        fillColor: Color(0xFF141414),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendChatMessage(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: _loading || !_joined ? null : _pickAndSendFile,
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: const Text('Anexo'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _loading || !_joined ? null : _sendChatMessage,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Enviar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndSendFile() async {
    if (_engine == null || !_joined) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entre no canal antes de enviar arquivos.')),
      );
      return;
    }

    final maxSize = 3 * 1024 * 1024; // 3MB
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    
    final file = result.files.first;
    if (file.bytes == null) return;
    
    if (file.bytes!.length > maxSize) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo muito grande para enviar pelo chat (máx 3MB).')),
      );
      return;
    }
    
    int? toUid;
    String? toName;
    final recipient = _recipientController.text.trim();
    if (recipient.isNotEmpty) {
      final asInt = int.tryParse(recipient);
      if (asInt != null) {
        toUid = asInt;
      } else {
        final match = _userNames.entries.firstWhere(
          (e) => e.value.toLowerCase() == recipient.toLowerCase(),
          orElse: () => const MapEntry(-1, ''),
        );
        if (match.key != -1) {
          toUid = match.key;
        } else {
          toName = recipient;
        }
      }
    }
    
    // Upload para o backend e enviar um link leve via data stream
    final backendBase = (dotenv.env['BACKEND_URL']?.trim().isNotEmpty ?? false)
        ? dotenv.env['BACKEND_URL']!.trim()
        : 'http://localhost:8082';
    final uri = Uri.parse('$backendBase/upload');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha no upload (${response.statusCode}).')),
        );
        return;
      }

      final resp = jsonDecode(response.body);
      final url = resp['url'] as String?;
      final size = (resp['size'] is int) ? resp['size'] as int : file.bytes!.length;
      if (url == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resposta do servidor inválida.')),
        );
        return;
      }

      // Adicionar mensagem local com link
      setState(() {
        _messages.add(_FileMessage(
          fromUid: _localUid,
          fromName: _userNames[_localUid] ?? _effectiveDisplayName(),
          timestamp: DateTime.now(),
          fileName: file.name,
          mimeType: 'application/octet-stream',
          bytes: Uint8List(0),
          url: url,
          size: size,
          toUid: toUid,
          toName: toName,
        ));
      });

      // Enviar payload leve via data stream
      final payload = jsonEncode({
        'type': 'file-link',
        'fileName': file.name,
        'mimeType': 'application/octet-stream',
        'url': url,
        'size': size,
        'fromUid': _localUid,
        'fromName': _userNames[_localUid] ?? _effectiveDisplayName(),
        if (toUid != null) 'toUid': toUid,
        if (toName != null) 'toName': toName,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final msgBytes = Uint8List.fromList(payload.codeUnits);
      if (_dataStreamId == null) {
        try {
          _dataStreamId = await _engine!.createDataStreamEx(
            config: const DataStreamConfig(syncWithAudio: false, ordered: true),
            connection: _mainConnection,
          );
        } catch (_) {
          try {
            _dataStreamId = await _engine!.createDataStream(
              const DataStreamConfig(syncWithAudio: false, ordered: true),
            );
          } catch (_) {}
        }
      }

      final streamId = _dataStreamId;
      if (streamId != null) {
        try {
          await _engine!.sendStreamMessageEx(
            streamId: streamId,
            data: msgBytes,
            length: msgBytes.length,
            connection: _mainConnection,
          );
        } catch (_) {
          try {
            await _engine!.sendStreamMessage(
              streamId: streamId,
              data: msgBytes,
              length: msgBytes.length,
            );
          } catch (_) {}
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Arquivo enviado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro no upload: $e')),
      );
    }
  }

  Widget _fileMessageTile(BuildContext context, _FileMessage m) {
    final isOwnMessage = m.fromUid == _localUid;
    final bytesLen = m.size ?? m.bytes.length;
    final sizeKB = (bytesLen / 1024).toStringAsFixed(1);
    final toLabel = (m.toUid != null)
        ? '#${m.toUid}'
        : (m.toName != null ? '@${m.toName}' : 'all');
    
    return Align(
      alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: kIsWeb
            ? () {
                if (m.url != null && m.url!.isNotEmpty) {
                  _downloadFromUrlWeb(m.url!, m.fileName);
                } else {
                  _downloadFileWeb(m.fileName, m.bytes);
                }
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: isOwnMessage ? Colors.blueGrey.shade700 : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                '${m.fromName} → $toLabel',
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.insert_drive_file, size: 18, color: Colors.white70),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      m.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '($sizeKB KB)',
                    style: const TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadFileWeb(String fileName, Uint8List bytes) {
    if (!kIsWeb) return;
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao fazer download do arquivo')),
      );
    }
  }

  void _downloadFromUrlWeb(String url, String fileName) {
    if (!kIsWeb) return;
    () async {
      try {
        final resp = await html.HttpRequest.request(
          url,
          method: 'GET',
          responseType: 'arraybuffer',
          withCredentials: false,
        );
        final data = resp.response as ByteBuffer?;
        if (data == null) {
          throw Exception('empty response');
        }
        final blob = html.Blob([data]);
        final objectUrl = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: objectUrl)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(objectUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download iniciado…')),
        );
      } catch (_) {
        // fallback: open in new tab (call tab stays)
        try {
          final anchor = html.AnchorElement(href: url)
            ..target = '_blank'
            ..setAttribute('download', fileName)
            ..click();
        } catch (_) {}
      }
    }();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(label),
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
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(label, style: const TextStyle(fontSize: 12)),
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
