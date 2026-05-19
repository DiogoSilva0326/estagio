import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  String _initialRoute() {
    if (!kIsWeb) {
      return Routes.home;
    }

    final uri = Uri.base;
    final normalizedPath = Routes.normalizePath(uri.path);
    if (normalizedPath.isEmpty || normalizedPath == Routes.home) {
      return Routes.home;
    }

    return uri.hasQuery ? '$normalizedPath?${uri.query}' : normalizedPath;
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) return null;

    final uri = Uri.parse(name);
    final normalized = Routes.normalizePath(uri.path);

    final dynamicPage = Routes.resolveDynamic(uri);
    if (dynamicPage != null) {
      return _AppPageRoute(
        settings: RouteSettings(name: name, arguments: settings.arguments),
        builder: (_) => dynamicPage,
      );
    }

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
            initialRoute: _initialRoute(),
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
