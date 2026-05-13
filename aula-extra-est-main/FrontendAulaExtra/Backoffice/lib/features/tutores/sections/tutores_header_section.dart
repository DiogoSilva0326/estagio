import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../explicadores/widgets/explicadores_add_button.dart';
import '../../explicadores/widgets/explicadores_search_field.dart';

class TutoresHeaderSection extends StatelessWidget {
  const TutoresHeaderSection({
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
              ExplicadoresSearchField(
                controller: searchController,
                onChanged: onSearchChanged,
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: ExplicadoresAddButton(label: 'Adicionar Tutor'),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: _HeaderText()),
            const SizedBox(width: 24),
            ExplicadoresSearchField(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
            const SizedBox(width: 18.637),
            const ExplicadoresAddButton(label: 'Adicionar Tutor'),
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
          'Tutores',
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
          'Gestão de perfis e aprovações de tutores.',
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
