import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/configuracoes_save_button.dart';

class ConfiguracoesHeaderSection extends StatelessWidget {
  const ConfiguracoesHeaderSection({required this.onSave, super.key});

  final VoidCallback onSave;

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
              ConfiguracoesSaveButton(onPressed: onSave),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: _HeaderText()),
            const SizedBox(width: 24),
            ConfiguracoesSaveButton(onPressed: onSave),
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
          'Configurações de Sistema',
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
          'Gestão dos parâmetros globais da plataforma, segurança, faturação e notificações.',
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
