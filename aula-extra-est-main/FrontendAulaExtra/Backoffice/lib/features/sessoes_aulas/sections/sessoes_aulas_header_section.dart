import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../alunos/widgets/export_csv_button.dart';
import '../widgets/sessoes_aulas_search_field.dart';

class SessoesAulasHeaderSection extends StatelessWidget {
  const SessoesAulasHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 980;

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HeaderText(),
              SizedBox(height: 24),
              SessoesAulasSearchField(),
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
            SessoesAulasSearchField(),
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
          'Sessões e Videochamadas',
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
          'Monitorização de aulas via Agora RTC.',
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
