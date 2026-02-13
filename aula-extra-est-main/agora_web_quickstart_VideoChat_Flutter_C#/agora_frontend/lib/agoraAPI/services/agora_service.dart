import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

/// Enum for screen share UID detection
enum RtcRole { publisher, subscriber }

/// Wrapper service for Agora RTC Engine management
class AgoraService {
  RtcEngineEx? _engine;
  late final RtcConnection _mainConnection;

  String? _currentChannel;
  int? _localUid;
  int? _screenShareUid;

  /// Callbacks for UI updates
  Function(String? error)? onError;
  Function()? onJoinChannelSuccess;
  Function()? onLeaveChannel;
  Function(int remoteUid)? onUserJoined;
  Function(int remoteUid)? onUserOffline;
  Function(int uid, String userName)? onUserInfoUpdated;
  Function(int remoteUid, String name)? onStreamMessage;
  Function(bool isSharing)? onScreenShareStateChanged;
  Function(int remoteUid)? onRemoteScreenShareJoined;
  Function()? onRemoteScreenShareLeft;

  /// State getters
  bool get isInitialized => _engine != null;
  bool get isJoined => _currentChannel != null && _currentChannel!.isNotEmpty;
  String? get currentChannel => _currentChannel;
  int? get localUid => _localUid;
  int? get screenShareUid => _screenShareUid;

  /// Detect if UID is a screen share UID (convention: baseUid * 100 + 99)
  static bool isScreenShareUid(int uid) => uid % 100 == 99;

  /// Generate screen share UID from base UID
  static int screenShareUidFor(int baseUid) {
    final candidate = baseUid * 100 + 99;
    if (candidate > 0xFFFFFFFF) {
      throw StateError('UID too large for screen share: $candidate');
    }
    return candidate;
  }

  /// Initialize the Agora engine
  Future<void> initialize(String appId) async {
    final engine = createAgoraRtcEngineEx();
    await engine.initialize(RtcEngineContext(appId: appId));
    await engine.enableAudio();
    await engine.enableVideo();

    // For Web compatibility
    if (kIsWeb) {
      await engine.setChannelProfile(
        ChannelProfileType.channelProfileLiveBroadcasting,
      );
      await engine.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster,
      );
    }

    _setupEventHandlers(engine);
    _engine = engine;
  }

  /// Setup RTC event handlers
  void _setupEventHandlers(RtcEngineEx engine) {
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) => onError?.call('[Agora] $err: $msg'),
        onJoinChannelSuccess: (connection, elapsed) {
          if (connection.localUid != _localUid) return;
          onJoinChannelSuccess?.call();
        },
        onLeaveChannel: (connection, stats) {
          // Ignore screen share connection leave events
          if (connection.localUid != _localUid) {
            if (connection.localUid == _screenShareUid) {
              _screenShareUid = null;
              onRemoteScreenShareLeft?.call();
            }
            return;
          }
          _currentChannel = null;
          _localUid = null;
          _screenShareUid = null;
          onLeaveChannel?.call();
        },
        onLocalVideoStateChanged: (source, state, reason) {
          // Only care about screen share state changes
          if (source != VideoSourceType.videoSourceScreen &&
              source != VideoSourceType.videoSourceScreenPrimary) {
            return;
          }

          final isSharing = state == LocalVideoStreamState.localVideoStreamStateCapturing ||
              state == LocalVideoStreamState.localVideoStreamStateEncoding;
          onScreenShareStateChanged?.call(isSharing);

          if (state == LocalVideoStreamState.localVideoStreamStateFailed) {
            onError?.call('[ScreenShare] failed: $reason');
          }
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          // Ignore our own UIDs
          if (remoteUid == _localUid || remoteUid == _screenShareUid) {
            return;
          }
          if (isScreenShareUid(remoteUid)) {
            onRemoteScreenShareJoined?.call(remoteUid);
          }
          onUserJoined?.call(remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          onUserOffline?.call(remoteUid);
        },
        onUserInfoUpdated: (uid, info) {
          final account = info.userAccount;
          if (account != null && account.isNotEmpty) {
            onUserInfoUpdated?.call(uid, account);
          }
        },
        onStreamMessage: (connection, remoteUid, streamId, data, length, sentTs) {
          try {
            final message = String.fromCharCodes(data);
            final decoded = jsonDecode(message);
            if (decoded is Map && decoded['type'] == 'name' && decoded['name'] is String) {
              onStreamMessage?.call(remoteUid, decoded['name'] as String);
            }
          } catch (_) {
            // Ignore malformed messages
          }
        },
      ),
    );
  }

  /// Join a channel with optional display name
  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
    String? displayName,
    String? appId,
  }) async {
    if (_engine == null) {
      throw StateError('Engine not initialized. Call initialize() first.');
    }

    _currentChannel = channelName;
    _localUid = uid;
    _mainConnection = RtcConnection(
      channelId: channelName,
      localUid: uid,
    );

    // Register user account with display name if provided
    if (displayName != null && displayName.isNotEmpty && appId != null) {
      try {
        await _engine!.registerLocalUserAccount(
          appId: appId,
          userAccount: displayName,
        );
      } catch (e) {
        // Silently ignore if registration fails; continue with join
      }
    }

    await _engine!.startPreview();
    await _engine!.joinChannelEx(
      token: token,
      connection: _mainConnection,
      options: const ChannelMediaOptions(
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  /// Leave the current channel
  Future<void> leaveChannel() async {
    if (_engine == null || _currentChannel == null) return;
    await _engine!.leaveChannelEx(
      connection: _mainConnection,
      options: const LeaveChannelOptions(),
    );
  }

  /// Start screen sharing on a secondary connection
  Future<void> startScreenShare({
    required String token,
    required int uid,
  }) async {
    if (_engine == null || _currentChannel == null || _localUid == null) {
      throw StateError('Must join channel first before screen sharing');
    }

    _screenShareUid = screenShareUidFor(_localUid!);

    try {
      final screenConnection = RtcConnection(
        channelId: _currentChannel!,
        localUid: _screenShareUid!,
      );

      await _engine!.joinChannelEx(
        token: token,
        connection: screenConnection,
        options: const ChannelMediaOptions(
          publishScreenTrack: true,
          publishCameraTrack: false,
          publishMicrophoneTrack: false,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );
    } catch (e) {
      _screenShareUid = null;
      rethrow;
    }
  }

  /// Stop screen sharing
  Future<void> stopScreenShare() async {
    if (_engine == null || _screenShareUid == null) return;

    final screenConnection = RtcConnection(
      channelId: _currentChannel!,
      localUid: _screenShareUid!,
    );

    try {
      // Stop screen capture and leave screen share connection
      await _engine!.stopScreenCapture();
      await _engine!.leaveChannelEx(
        connection: screenConnection,
        options: const LeaveChannelOptions(),
      );
    } finally {
      _screenShareUid = null;
    }
  }

  /// Create data stream for broadcasting name/metadata (with fallback)
  Future<int?> createDataStream() async {
    if (_engine == null) {
      throw StateError('Engine not initialized');
    }

    int? streamId;
    
    // Try Ex method first (more reliable for multi-connection setups)
    try {
      streamId = await _engine!.createDataStreamEx(
        config: const DataStreamConfig(syncWithAudio: false, ordered: true),
        connection: _mainConnection,
      );
    } catch (_) {
      // Fallback to non-Ex method
      try {
        streamId = await _engine!.createDataStream(
          const DataStreamConfig(syncWithAudio: false, ordered: true),
        );
      } catch (_) {}
    }
    
    return streamId;
  }

  /// Send stream message with metadata (with fallback)
  Future<void> sendStreamMessage({
    required int streamId,
    required Map<String, dynamic> message,
  }) async {
    if (_engine == null || !isJoined) return;

    final payload = jsonEncode(message);
    final bytes = Uint8List.fromList(payload.codeUnits);

    try {
      // Try Ex method first
      await _engine!.sendStreamMessageEx(
        streamId: streamId,
        data: bytes,
        length: bytes.length,
        connection: _mainConnection,
      );
    } catch (_) {
      // Fallback to non-Ex method
      try {
        await _engine!.sendStreamMessage(
          streamId: streamId,
          data: bytes,
          length: bytes.length,
        );
      } catch (_) {
        // Silently ignore send failures
      }
    }
  }

  /// Get user info by UID (with retry)
  Future<UserInfo?> getUserInfo(int uid, {int maxRetries = 3}) async {
    if (_engine == null) return null;

    for (int i = 0; i < maxRetries; i++) {
      try {
        final info = await _engine!.getUserInfoByUid(uid);
        return info;
      } catch (_) {
        if (i < maxRetries - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }
    return null;
  }

  /// Release engine and cleanup
  Future<void> dispose() async {
    if (_engine == null) return;
    await _engine!.release();
    _engine = null;
    _currentChannel = null;
    _localUid = null;
    _screenShareUid = null;
  }
}
