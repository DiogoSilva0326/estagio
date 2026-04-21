import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/avaliacoes_search_field.dart';

class AvaliacoesHeaderSection extends StatelessWidget {
  const AvaliacoesHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 920;

        if (stacked) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderText(),
              SizedBox(height: 24),
              AvaliacoesSearchField(),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _HeaderText()),
            SizedBox(width: 24),
            AvaliacoesSearchField(),
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
          'Avaliações e Reviews',
          style: TextStyle(
            color: Color(0xFF101828),
            fontSize: 41.933,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.67,
            height: 1.1,
          ),
        ),
        SizedBox(height: 4.659),
        Text(
          'Moderação de avaliações dos alunos aos explicadores.',
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
