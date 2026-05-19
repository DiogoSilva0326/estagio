import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class SessionBootstrapper extends StatefulWidget {
  const SessionBootstrapper({super.key, required this.child});

  final Widget child;

  @override
  State<SessionBootstrapper> createState() => _SessionBootstrapperState();
}

class _SessionBootstrapperState extends State<SessionBootstrapper>
    with WidgetsBindingObserver {
  static const Duration _sessionCheckInterval = Duration(minutes: 1);

  final TokenStorage _tokenStorage = TokenStorage();
  bool _isBootstrapping = true;
  bool _isCheckingSession = false;
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
    _startSessionMonitoring();
  }

  Future<void> _bootstrap() async {
    try {
      final token = await _tokenStorage.loadToken();
      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;
        setState(() => _isBootstrapping = false);
        return;
      }

      // O refresh() já foi corrigido para ler a preferência, 
      // por isso aqui já deve vir a role correta (Tutor/Psicólogo).
      final session = await AuthService(tokenStorage: _tokenStorage).refresh();
      
      if (!mounted) return;
      
      // Garante que aplicamos a role da sessão ao provider
      AuthService.applySessionToProvider(context.read<UserProvider>(), session);
      
    } catch (_) {
      await SessionManager.instance.handleExpiredSession();
    } finally {
      if (mounted) {
        setState(() => _isBootstrapping = false);
      }
    }
  }

  void _startSessionMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(
      _sessionCheckInterval,
      (_) => _runSessionCheck(),
    );
  }

  Future<void> _runSessionCheck() async {
    if (_isBootstrapping || _isCheckingSession) {
      return;
    }

    _isCheckingSession = true;
    try {
      final token = await _tokenStorage.loadToken();
      if (token == null || token.trim().isEmpty) {
        return;
      }

      final session = await AuthService(tokenStorage: _tokenStorage).refresh();
      if (!mounted) {
        return;
      }

      AuthService.applySessionToProvider(context.read<UserProvider>(), session);
    } catch (_) {
      await SessionManager.instance.handleExpiredSession();
    } finally {
      _isCheckingSession = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runSessionCheck();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isBootstrapping) {
      return const Material(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return widget.child;
  }
}
