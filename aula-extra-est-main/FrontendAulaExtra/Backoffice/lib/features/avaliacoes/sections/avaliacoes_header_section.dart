import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/avaliacoes_search_field.dart';

class AvaliacoesHeaderSection extends StatelessWidget {
  const AvaliacoesHeaderSection({
    super.key,
    this.searchController,
    this.onSearchChanged,
  });

  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 920;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderText(),
              const SizedBox(height: 24),
              AvaliacoesSearchField(
                controller: searchController,
                onChanged: onSearchChanged,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: _HeaderText()),
            const SizedBox(width: 24),
            AvaliacoesSearchField(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
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
          'Moderacao de avaliacoes submetidas as aulas e aos professores.',
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
