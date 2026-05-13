import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../widgets/export_report_button.dart';

class PagamentosHeaderSection extends StatelessWidget {
  const PagamentosHeaderSection({
    super.key,
    this.onExportPressed,
    this.exportEnabled = false,
  });

  final VoidCallback? onExportPressed;
  final bool exportEnabled;

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
                child: ExportReportButton(
                  onPressed: onExportPressed,
                  enabled: exportEnabled,
                ),
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: _HeaderText()),
            const SizedBox(width: 24),
            ExportReportButton(
              onPressed: onExportPressed,
              enabled: exportEnabled,
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
          'Financeiro',
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
          'Gestão de transações e comissões.',
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
