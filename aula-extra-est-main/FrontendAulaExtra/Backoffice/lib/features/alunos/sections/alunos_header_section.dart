import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/alunos_search_field.dart';
import '../widgets/export_csv_button.dart';

class AlunosHeaderSection extends StatelessWidget {
  const AlunosHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 920;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HeaderText(),
              SizedBox(height: 24),
              AlunosSearchField(),
              SizedBox(height: 16),
              Align(alignment: Alignment.centerLeft, child: ExportCsvButton()),
            ],
          );
        }

        return const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _HeaderText()),
            SizedBox(width: 24),
            AlunosSearchField(),
            SizedBox(width: 18.637),
            ExportCsvButton(),
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
          'Alunos',
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
          'Gestão de contas, planos e atividade dos alunos.',
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
