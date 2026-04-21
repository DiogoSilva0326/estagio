import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../sections/avaliacoes_overview_section.dart';

class AvaliacoesPage extends StatelessWidget {
  const AvaliacoesPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  Widget build(BuildContext context) {
    return const BackofficeScaffold(
      currentRoute: AppRoutes.avaliacoes,
      title: 'Avaliações',
      showTopBar: false,
      body: _AvaliacoesBody(),
    );
  }
}

class _AvaliacoesBody extends StatelessWidget {
  const _AvaliacoesBody();

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
                maxWidth: AvaliacoesPage._contentMaxWidth,
              ),
              child: const AvaliacoesOverviewSection(),
            ),
          ),
        );
      },
    );
  }
}
