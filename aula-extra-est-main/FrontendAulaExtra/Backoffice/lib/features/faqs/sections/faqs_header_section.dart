import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/faqs_create_button.dart';

class FaqsHeaderSection extends StatelessWidget {
  const FaqsHeaderSection({
    required this.onCreate,
    required this.onCreateCategory,
    super.key,
  });

  final VoidCallback onCreate;
  final VoidCallback onCreateCategory;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderText(),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FaqsCreateButton(
                    onPressed: onCreateCategory,
                    label: 'Nova categoria',
                    icon: Icons.category_outlined,
                  ),
                  FaqsCreateButton(onPressed: onCreate),
                ],
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: _HeaderText()),
            const SizedBox(width: 24),
            FaqsCreateButton(
              onPressed: onCreateCategory,
              label: 'Nova categoria',
              icon: Icons.category_outlined,
            ),
            const SizedBox(width: 12),
            FaqsCreateButton(onPressed: onCreate),
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
          'FAQs',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 41.933,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.67,
            height: 1.1,
          ),
        ),
        SizedBox(height: 4.659),
        Text(
          'Gestão das perguntas frequentes, categorias e estado de publicação.',
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
