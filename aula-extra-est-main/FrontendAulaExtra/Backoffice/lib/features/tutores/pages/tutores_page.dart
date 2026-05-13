import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../sections/tutores_overview_section.dart';

class TutoresPage extends StatelessWidget {
  const TutoresPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  Widget build(BuildContext context) {
    return const BackofficeScaffold(
      currentRoute: AppRoutes.tutores,
      title: 'Tutores',
      showTopBar: false,
      body: _TutoresBody(),
    );
  }
}

class _TutoresBody extends StatelessWidget {
  const _TutoresBody();

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
                maxWidth: TutoresPage._contentMaxWidth,
              ),
              child: const TutoresOverviewSection(),
            ),
          ),
        );
      },
    );
  }
}
