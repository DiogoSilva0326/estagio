import 'package:flutter/material.dart';

import 'design/theme/app_theme.dart';
import 'routes/app_router.dart';

class BackofficeApp extends StatelessWidget {
  const BackofficeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aula Extra Backoffice',
      theme: AppTheme.light(),
      initialRoute: AppRouter.initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
