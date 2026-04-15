import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_layout.dart';
import 'package:flutter/material.dart';

class PagamentosSummaryCard extends StatelessWidget {
  const PagamentosSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Gradient gradient;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PagamentosProfessorLayout.summaryCardWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            PagamentosProfessorLayout.summaryCardRadius,
          ),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 17.973,
              offset: const Offset(0, 11.982),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 7.189,
              offset: const Offset(0, 4.793),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PagamentosProfessorLayout.summaryCardPadding,
            PagamentosProfessorLayout.summaryCardPadding,
            PagamentosProfessorLayout.summaryCardPadding,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: PagamentosProfessorLayout.summaryIconSize,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0.9,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize:
                              PagamentosProfessorLayout.summaryLabelFontSize,
                          fontWeight: FontWeight.w500,
                          height:
                              PagamentosProfessorLayout.summaryLabelLineHeight /
                              PagamentosProfessorLayout.summaryLabelFontSize,
                        ),
                      ),
                    ),
                    Icon(
                      icon,
                      color: Colors.white,
                      size: PagamentosProfessorLayout.summaryIconSize,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9.586),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: PagamentosProfessorLayout.summaryValueFontSize,
                  fontWeight: FontWeight.w700,
                  height:
                      PagamentosProfessorLayout.summaryValueLineHeight /
                      PagamentosProfessorLayout.summaryValueFontSize,
                ),
              ),
              const SizedBox(height: 9.586),
              Opacity(
                opacity: 0.8,
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: PagamentosProfessorLayout.summarySubLabelFontSize,
                    fontWeight: FontWeight.w400,
                    height:
                        PagamentosProfessorLayout.summarySubLabelLineHeight /
                        PagamentosProfessorLayout.summarySubLabelFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
