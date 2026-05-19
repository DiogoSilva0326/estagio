import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:flutter/material.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  final TokenStorage _tokenStorage = TokenStorage();

  GlobalKey<NavigatorState>? _navigatorKey;
  UserProvider? _userProvider;
  bool _isHandlingExpiration = false;

  void configure({
    required GlobalKey<NavigatorState> navigatorKey,
    required UserProvider userProvider,
  }) {
    _navigatorKey = navigatorKey;
    _userProvider = userProvider;
  }

  Future<void> clearSessionState() async {
    await _tokenStorage.clearToken();
    await _tokenStorage.clearPreferredRole();
    _userProvider?.setAccount(null);
    _userProvider?.setRole(Role.none);
  }

  Future<void> handleExpiredSession() async {
    if (_isHandlingExpiration) return;

    _isHandlingExpiration = true;
    try {
      await clearSessionState();
      final navigator = _navigatorKey?.currentState;
      if (navigator != null) {
        navigator.pushNamedAndRemoveUntil('/login', (route) => false);
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigatorKey?.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      });
    } finally {
      _isHandlingExpiration = false;
    }
  }
}
