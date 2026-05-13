import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/newsletter_create_button.dart';

class NewsletterHeaderSection extends StatelessWidget {
  const NewsletterHeaderSection({
    required this.onCreate,
    this.creating = false,
    super.key,
  });

  final VoidCallback? onCreate;
  final bool creating;

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
              NewsletterCreateButton(onPressed: onCreate),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: _HeaderText()),
            const SizedBox(width: 24),
            if (creating)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.6),
              ),
            if (creating) const SizedBox(width: 18),
            NewsletterCreateButton(onPressed: onCreate),
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
          'Newsletter',
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
          'Gestão de campanhas, audiências e desempenho de envio.',
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
