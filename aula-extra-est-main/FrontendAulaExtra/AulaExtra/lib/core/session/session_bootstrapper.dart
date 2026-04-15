import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SessionBootstrapper extends StatefulWidget {
  const SessionBootstrapper({super.key, required this.child});

  final Widget child;

  @override
  State<SessionBootstrapper> createState() => _SessionBootstrapperState();
}

class _SessionBootstrapperState extends State<SessionBootstrapper> {
  final TokenStorage _tokenStorage = TokenStorage();
  bool _isBootstrapping = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final token = await _tokenStorage.loadToken();
      if (token == null || token.trim().isEmpty) {
        if (!mounted) return;
        setState(() => _isBootstrapping = false);
        return;
      }

      final session = await AuthService(tokenStorage: _tokenStorage).refresh();
      if (!mounted) return;
      AuthService.applySessionToProvider(context.read<UserProvider>(), session);
    } catch (_) {
      await SessionManager.instance.handleExpiredSession();
    } finally {
      if (mounted) {
        setState(() => _isBootstrapping = false);
      }
    }
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
