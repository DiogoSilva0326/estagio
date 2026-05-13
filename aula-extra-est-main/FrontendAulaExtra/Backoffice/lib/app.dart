import 'package:flutter/material.dart';

import 'core/auth/backoffice_session_controller.dart';
import 'design/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';

class BackofficeApp extends StatefulWidget {
  const BackofficeApp({super.key});

  @override
  State<BackofficeApp> createState() => _BackofficeAppState();
}

class _BackofficeAppState extends State<BackofficeApp> {
  final BackofficeSessionController _session = BackofficeSessionController.instance;

  @override
  void initState() {
    super.initState();
    _session.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        if (!_session.initialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Aula Extra Backoffice',
            theme: AppTheme.light(),
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp(
          key: ValueKey(_session.isAuthenticated),
          debugShowCheckedModeBanner: false,
          title: 'Aula Extra Backoffice',
          theme: AppTheme.light(),
          initialRoute: _session.isAuthenticated
              ? AppRoutes.dashboard
              : AppRoutes.login,
          onGenerateRoute: AppRouter.onGenerateRoute,
        );
      },
    );
  }
}
