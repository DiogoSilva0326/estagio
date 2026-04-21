import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/areas_disciplinas_add_button.dart';

class AreasDisciplinasHeaderSection extends StatelessWidget {
  const AreasDisciplinasHeaderSection({super.key, this.onAddArea});

  final VoidCallback? onAddArea;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 760;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderText(),
              const SizedBox(height: 24),
              AreasDisciplinasAddButton(onPressed: onAddArea),
            ],
          );
        }

        return Row(
          children: [
            const Expanded(child: _HeaderText()),
            const SizedBox(width: 24),
            AreasDisciplinasAddButton(onPressed: onAddArea),
          ],
        );
      },
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catálogo Educativo',
          style: TextStyle(
            color: Color(0xFF101828),
            fontSize: 34.944,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.41,
            height: 1.1,
          ),
        ),
        SizedBox(height: 4.659),
        Text(
          'Gestão de áreas de estudo e disciplinas.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16.307,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.1752,
          ),
        ),
      ],
    );
  }
}
