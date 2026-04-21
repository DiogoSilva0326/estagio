import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/novo_plano_button.dart';

class PlanosPrecosHeaderSection extends StatelessWidget {
  const PlanosPrecosHeaderSection({required this.onCreatePlan, super.key});

  final VoidCallback onCreatePlan;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 900;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderText(),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: NovoPlanoButton(onTap: onCreatePlan),
              ),
            ],
          );
        }

        return Row(
          children: [
            const Expanded(child: _HeaderText()),
            const SizedBox(width: 24),
            NovoPlanoButton(onTap: onCreatePlan),
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
          'Planos e Preços',
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
          'Gestão de preçários e comissões da plataforma.',
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
