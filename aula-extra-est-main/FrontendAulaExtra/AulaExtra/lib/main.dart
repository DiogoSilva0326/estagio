import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/routes.dart';
import 'design/theme/app_theme.dart';
import 'core/providers/user_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('pt_BR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final name = settings.name;
    if (name == null) return null;

    final normalized = name.length > 1 && name.endsWith('/') ? name.substring(0, name.length - 1) : name;
    final builder = Routes.all[normalized];
    if (builder == null) return null;

    return MaterialPageRoute(
      settings: RouteSettings(name: normalized, arguments: settings.arguments),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Aula Extra',
        theme: AppTheme.light(),
        initialRoute: Routes.home,
        routes: Routes.all,
        onGenerateRoute: _onGenerateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}