import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../sections/sessions_overview_section.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  static const double _contentMaxWidth = 1006.382;

  @override
  Widget build(BuildContext context) {
    return const BackofficeScaffold(
      currentRoute: AppRoutes.sessoesRecentes,
      title: 'Sessões Recentes',
      showTopBar: false,
      body: _SessionsBody(),
    );
  }
}

class _SessionsBody extends StatelessWidget {
  const _SessionsBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;
        final verticalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;

        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              verticalPadding,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: SessionsPage._contentMaxWidth,
              ),
              child: const SessionsOverviewSection(),
            ),
          ),
        );
      },
    );
  }
}
