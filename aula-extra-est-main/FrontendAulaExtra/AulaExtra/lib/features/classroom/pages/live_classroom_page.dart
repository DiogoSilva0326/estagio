import 'package:aula_extra/core/data/lesson_classroom/dtos/lesson_classroom_entry_dto.dart';
import 'package:aula_extra/features/classroom/widgets/whiteboard_panel.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

enum ClassroomFocusMode { grid, screen, whiteboard }

class LiveClassroomPage extends StatefulWidget {
  const LiveClassroomPage({super.key, required this.entry});

  final LessonClassroomEntryDto entry;

  @override
  State<LiveClassroomPage> createState() => _LiveClassroomPageState();
}

class _LiveClassroomPageState extends State<LiveClassroomPage> {
  final Set<int> _remoteUids = <int>{};

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
  ClassroomFocusMode _focusMode = ClassroomFocusMode.grid;
  ClassroomFocusMode? _focusModeBeforeScreenShare;

  int? get _localScreenShareUid => widget.entry.screenShare?.uid;

  bool get _isLocalScreenShareActive =>
      _localScreenShareActive || _isScreenSharing;

  bool get _hasScreenShare =>
      _isLocalScreenShareActive || _remoteScreenShareUid != null;

  bool get _whiteboardEnabled => widget.entry.whiteboard.isReady;

  bool get _captureSystemAudio => !kIsWeb;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _joinClassroom());
  }

  @override
  void dispose() {
    _engine?.release();
    super.dispose();
  }

  Future<void> _ensurePermissions() async {
    if (kIsWeb) return;
    await <Permission>[Permission.microphone, Permission.camera].request();
  }

  bool _isScreenShareUid(int uid) => uid % 100 == 99;

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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: centerStage,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            child: ListView.separated(
              itemCount: tiles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  AspectRatio(aspectRatio: 16 / 9, child: tiles[index]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1020),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _ClassroomHeader(
              title: widget.entry.lessonTitle.trim().isEmpty
                  ? 'Aula ao vivo'
                  : widget.entry.lessonTitle,
              subtitle:
                  '${widget.entry.localDisplayName} · sala ${widget.entry.channelName}',
              isLoading: _loading,
              isMuted: _isMuted,
              isVideoOff: _isVideoOff,
              isWhiteboardOpen: _focusMode == ClassroomFocusMode.whiteboard,
              isScreenSharing: _isLocalScreenShareActive,
              canShareScreen:
                  widget.entry.isHost &&
                  widget.entry.screenShare != null &&
                  !_hasScreenShare,
              canStopScreenShare:
                  widget.entry.isHost && _isLocalScreenShareActive,
              canOpenWhiteboard: _whiteboardEnabled && _joined,
              onLeave: _joined && !_loading ? _leaveClassroom : null,
              onToggleMute: _joined ? _toggleMute : null,
              onToggleVideo: _joined ? _toggleVideo : null,
              onOpenWhiteboard: _joined ? _openWhiteboard : null,
              onCloseWhiteboard: _joined ? _closeWhiteboard : null,
              onStartScreenShare: _joined ? _startScreenShare : null,
              onStopScreenShare: _joined ? _stopScreenShare : null,
            ),
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: Colors.red.withValues(alpha: 0.2),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            Expanded(child: _buildContent()),
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
    required this.isLoading,
    required this.isMuted,
    required this.isVideoOff,
    required this.isWhiteboardOpen,
    required this.isScreenSharing,
    required this.canShareScreen,
    required this.canStopScreenShare,
    required this.canOpenWhiteboard,
    required this.onLeave,
    required this.onToggleMute,
    required this.onToggleVideo,
    required this.onOpenWhiteboard,
    required this.onCloseWhiteboard,
    required this.onStartScreenShare,
    required this.onStopScreenShare,
  });

  final String title;
  final String subtitle;
  final bool isLoading;
  final bool isMuted;
  final bool isVideoOff;
  final bool isWhiteboardOpen;
  final bool isScreenSharing;
  final bool canShareScreen;
  final bool canStopScreenShare;
  final bool canOpenWhiteboard;
  final VoidCallback? onLeave;
  final VoidCallback? onToggleMute;
  final VoidCallback? onToggleVideo;
  final VoidCallback? onOpenWhiteboard;
  final VoidCallback? onCloseWhiteboard;
  final VoidCallback? onStartScreenShare;
  final VoidCallback? onStopScreenShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF121A2B),
        border: Border(bottom: BorderSide(color: Color(0xFF273046))),
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
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            tooltip: isMuted ? 'Ativar microfone' : 'Desativar microfone',
            onPressed: onToggleMute,
            icon: Icon(isMuted ? Icons.mic_off : Icons.mic),
            color: isMuted ? Colors.redAccent : Colors.white,
          ),
          IconButton(
            tooltip: isVideoOff ? 'Ativar câmara' : 'Desativar câmara',
            onPressed: onToggleVideo,
            icon: Icon(isVideoOff ? Icons.videocam_off : Icons.videocam),
            color: isVideoOff ? Colors.redAccent : Colors.white,
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: isScreenSharing
                ? (canStopScreenShare ? onStopScreenShare : null)
                : (canShareScreen ? onStartScreenShare : null),
            icon: Icon(
              isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
            ),
            label: Text(isScreenSharing ? 'Parar partilha' : 'Partilhar ecrã'),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: isWhiteboardOpen
                ? onCloseWhiteboard
                : (canOpenWhiteboard ? onOpenWhiteboard : null),
            icon: Icon(isWhiteboardOpen ? Icons.close_fullscreen : Icons.draw),
            label: Text(
              isWhiteboardOpen ? 'Fechar whiteboard' : 'Abrir whiteboard',
            ),
          ),
          const SizedBox(width: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB3261E),
            ),
            onPressed: onLeave,
            icon: const Icon(Icons.call_end),
            label: const Text('Sair da aula'),
          ),
        ],
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
      borderRadius: BorderRadius.circular(16),
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
                  borderRadius: BorderRadius.circular(12),
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
