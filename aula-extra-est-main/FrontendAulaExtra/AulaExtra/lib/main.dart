import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/routes.dart';
import 'design/theme/app_theme.dart';
import 'core/providers/user_provider.dart';
import 'core/session/session_bootstrapper.dart';
import 'core/session/session_manager.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class _AppPageRoute<T> extends PageRouteBuilder<T> {
  _AppPageRoute({
    required WidgetBuilder builder,
    required RouteSettings settings,
  }) : super(
         settings: settings,
         opaque: true,
         barrierColor: null,
         pageBuilder: (context, animation, secondaryAnimation) => ColoredBox(
           color: Theme.of(context).scaffoldBackgroundColor,
           child: builder(context),
         ),
         transitionDuration: const Duration(milliseconds: 180),
         reverseTransitionDuration: const Duration(milliseconds: 140),
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
             reverseCurve: Curves.easeInCubic,
           );

           return FadeTransition(
             opacity: curvedAnimation,
             child: child,
           );
         },
       );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) return null;

    final normalized = name.length > 1 && name.endsWith('/')
        ? name.substring(0, name.length - 1)
        : name;
    final builder = Routes.all[normalized];
    if (builder == null) return null;

    return _AppPageRoute(
      settings: RouteSettings(name: normalized, arguments: settings.arguments),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          SessionManager.instance.configure(
            navigatorKey: appNavigatorKey,
            userProvider: userProvider,
          );

          return MaterialApp(
            navigatorKey: appNavigatorKey,
            title: 'Aula Extra',
            theme: AppTheme.light(),
            initialRoute: Routes.home,
            onGenerateRoute: _onGenerateRoute,
            onUnknownRoute: (settings) => _AppPageRoute(
              settings: settings,
              builder: Routes.all[Routes.home]!,
            ),
            builder: (context, child) =>
                SessionBootstrapper(child: child ?? const SizedBox.shrink()),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
