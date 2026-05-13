import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/reclamacao_item.dart';

class ReclamacoesHeaderSection extends StatelessWidget {
  const ReclamacoesHeaderSection({
    required this.selectedSource,
    super.key,
  });

  final ReclamacaoSource selectedSource;

  @override
  Widget build(BuildContext context) {
    final subtitle = selectedSource == ReclamacaoSource.utilizadores
        ? 'Mensagens de reclamações contra outros utilizadores'
        : 'Mensagens de reclamações e disputas de pagamentos';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reclamações',
          style: TextStyle(
            color: Color(0xFF101828),
            fontSize: 41.933,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.67,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4.659),
        Text(
          subtitle,
          style: const TextStyle(
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
