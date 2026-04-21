import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../sections/pagamentos_overview_section.dart';

class PagamentosPage extends StatelessWidget {
  const PagamentosPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  Widget build(BuildContext context) {
    return const BackofficeScaffold(
      currentRoute: AppRoutes.pagamentos,
      title: 'Pagamentos & Faturação',
      showTopBar: false,
      body: _PagamentosBody(),
    );
  }
}

class _PagamentosBody extends StatelessWidget {
  const _PagamentosBody();

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
                maxWidth: PagamentosPage._contentMaxWidth,
              ),
              child: const PagamentosOverviewSection(),
            ),
          ),
        );
      },
    );
  }
}
