import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'services/agora_service.dart';
import 'services/token_service.dart';

/// Gerenciador centralizado para toda a funcionalidade do Agora
/// Facilita a reutilização em outros projetos
class AgoraManager {
  final AgoraService _agoraService = AgoraService();
  final TokenService _tokenService = TokenService();

  String? _appId;
  String? _currentChannel;
  int? _localUid;

  // Callbacks para eventos
  Function(String? error)? onError;
  Function()? onJoinSuccess;
  Function()? onLeaveChannel;
  Function(int uid)? onUserJoined;
  Function(int uid)? onUserOffline;
  Function(int uid, String name)? onUserNameUpdated;
  Function(bool isSharing)? onScreenShareStateChanged;
  Function(int uid)? onRemoteScreenShareJoined;
  Function()? onRemoteScreenShareLeft;

  // Getters para estado
  bool get isInitialized => _agoraService.isInitialized;
  bool get isJoined => _agoraService.isJoined;
  String? get currentChannel => _currentChannel;
  int? get localUid => _localUid;
  int? get screenShareUid => _agoraService.screenShareUid;

  /// Inicializar o Agora engine
  Future<void> initialize(String appId) async {
    _appId = appId;
    
    // Configurar callbacks
    _agoraService.onError = (error) => onError?.call(error);
    _agoraService.onJoinChannelSuccess = () => onJoinSuccess?.call();
    _agoraService.onLeaveChannel = () {
      _currentChannel = null;
      _localUid = null;
      onLeaveChannel?.call();
    };
    _agoraService.onUserJoined = (uid) => onUserJoined?.call(uid);
    _agoraService.onUserOffline = (uid) => onUserOffline?.call(uid);
    _agoraService.onUserInfoUpdated = (uid, name) => onUserNameUpdated?.call(uid, name);
    _agoraService.onStreamMessage = (uid, name) => onUserNameUpdated?.call(uid, name);
    _agoraService.onScreenShareStateChanged = (isSharing) => onScreenShareStateChanged?.call(isSharing);
    _agoraService.onRemoteScreenShareJoined = (uid) => onRemoteScreenShareJoined?.call(uid);
    _agoraService.onRemoteScreenShareLeft = () => onRemoteScreenShareLeft?.call();

    await _agoraService.initialize(appId);
  }

  /// Entrar em um canal
  Future<void> joinChannel({
    required String channelName,
    required String displayName,
    int? uid,
  }) async {
    if (!isInitialized) {
      throw StateError('AgoraManager não foi inicializado. Chame initialize() primeiro.');
    }

    _currentChannel = channelName;
    _localUid = uid ?? _generateUid();

    // Buscar token do backend
    final token = await _tokenService.fetchRtcToken(
      channelName: channelName,
      uid: _localUid!,
    );

    await _agoraService.joinChannel(
      token: token,
      channelName: channelName,
      uid: _localUid!,
      displayName: displayName,
      appId: _appId,
    );
  }

  /// Sair do canal
  Future<void> leaveChannel() async {
    await _agoraService.leaveChannel();
  }

  /// Iniciar compartilhamento de tela
  Future<void> startScreenShare() async {
    if (_currentChannel == null || _localUid == null) {
      throw StateError('Deve estar em um canal antes de compartilhar tela');
    }

    final screenShareUid = AgoraService.screenShareUidFor(_localUid!);
    
    // Buscar token para o UID de compartilhamento de tela
    final token = await _tokenService.fetchRtcToken(
      channelName: _currentChannel!,
      uid: screenShareUid,
    );

    await _agoraService.startScreenShare(
      token: token,
      uid: screenShareUid,
    );
  }

  /// Parar compartilhamento de tela
  Future<void> stopScreenShare() async {
    await _agoraService.stopScreenShare();
  }

  /// Criar data stream para enviar mensagens
  Future<int?> createDataStream() async {
    return await _agoraService.createDataStream();
  }

  /// Enviar mensagem através do data stream
  Future<void> sendStreamMessage({
    required int streamId,
    required Map<String, dynamic> message,
  }) async {
    await _agoraService.sendStreamMessage(
      streamId: streamId,
      message: message,
    );
  }

  /// Obter informação do usuário pelo UID
  Future<UserInfo?> getUserInfo(int uid) async {
    return await _agoraService.getUserInfo(uid);
  }

  /// Liberar recursos
  /// Liberar recursos
  Future<void> dispose() async {
    await _agoraService.dispose();
    _appId = null;
    _currentChannel = null;
    _localUid = null;
  }
  /// Gerar UID aleatório
  int _generateUid() {
    return Random().nextInt(0xFFFFFF) + 1;
  }
}
