import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../features/navigation/widgets/backoffice_sidebar.dart';

class BackofficeScaffold extends StatelessWidget {
  const BackofficeScaffold({
    required this.currentRoute,
    required this.title,
    required this.body,
    this.showTopBar = true,
    super.key,
  });

  final String currentRoute;
  final String title;
  final Widget body;
  final bool showTopBar;

  bool _useDrawer(double width) => width < 1100;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showDrawer = _useDrawer(constraints.maxWidth);

        return Scaffold(
          drawer: showDrawer
              ? Drawer(
                  width: AppDimensions.sidebarWidth,
                  child: BackofficeSidebar(
                    currentRoute: currentRoute,
                    onNavigate: (route) {
                      Navigator.of(context).pop();
                      if (route != currentRoute) {
                        Navigator.of(context).pushReplacementNamed(route);
                      }
                    },
                  ),
                )
              : null,
          body: Row(
            children: [
              if (!showDrawer)
                BackofficeSidebar(
                  currentRoute: currentRoute,
                  onNavigate: (route) {
                    if (route != currentRoute) {
                      Navigator.of(context).pushReplacementNamed(route);
                    }
                  },
                ),
              Expanded(
                child: Column(
                  children: [
                    if (showTopBar)
                      _BackofficeTopBar(
                        title: title,
                        showMenuButton: showDrawer,
                      ),
                    Expanded(
                      child: showTopBar
                          ? body
                          : SafeArea(bottom: false, child: body),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BackofficeTopBar extends StatelessWidget {
  const _BackofficeTopBar({required this.title, required this.showMenuButton});

  final String title;
  final bool showMenuButton;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Row(
          children: [
            if (showMenuButton)
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
            if (showMenuButton) const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
