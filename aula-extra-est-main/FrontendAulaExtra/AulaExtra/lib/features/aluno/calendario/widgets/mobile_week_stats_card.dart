import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:flutter/material.dart';

class MobileWeekStatsCard extends StatelessWidget {
  const MobileWeekStatsCard({
    super.key,
    required this.weekLessons,
    required this.pendingTasks,
    required this.nextLessonLabel,
  });

  final int weekLessons;
  final int pendingTasks;
  final String nextLessonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CalendarioConstants.mobileSurfaceColor,
        borderRadius: BorderRadius.circular(
          CalendarioConstants.mobileCardRadius,
        ),
        border: Border.all(color: CalendarioConstants.mobileBorderColor),
        boxShadow: CalendarioConstants.mobileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estatísticas',
            style: CalendarioConstants.mobileSectionTitleStyle,
          ),
          const SizedBox(height: 14),
          _StatRow(label: 'Aulas esta semana', value: '$weekLessons'),
          const SizedBox(height: 10),
          _StatRow(label: 'Tarefas pendentes', value: '$pendingTasks'),
          const SizedBox(height: 10),
          _StatRow(label: 'Próxima aula em', value: nextLessonLabel),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: CalendarioConstants.mobileStatLabelStyle),
        ),
        const SizedBox(width: 12),
        Text(value, style: CalendarioConstants.mobileStatValueStyle),
      ],
    );
  }
}
