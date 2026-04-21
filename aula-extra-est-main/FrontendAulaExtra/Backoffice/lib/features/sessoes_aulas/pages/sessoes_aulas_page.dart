import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../sections/sessoes_aulas_overview_section.dart';

class SessoesAulasPage extends StatelessWidget {
  const SessoesAulasPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  Widget build(BuildContext context) {
    return const BackofficeScaffold(
      currentRoute: AppRoutes.sessoesAulas,
      title: 'Sessões / Aulas',
      showTopBar: false,
      body: _SessoesAulasBody(),
    );
  }
}

class _SessoesAulasBody extends StatelessWidget {
  const _SessoesAulasBody();

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
                maxWidth: SessoesAulasPage._contentMaxWidth,
              ),
              child: const SessoesAulasOverviewSection(),
            ),
          ),
        );
      },
    );
  }
}
