import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/core/providers/user_provider.dart'; 
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

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
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    
    final weekLabel = userProvider.role == Role.student 
        ? 'Aulas esta semana' 
        : config.menu.statsSessionsLabel;
        
    final nextItemLabel = config.sessionsLabel == 'aulas' ? 'aula' : 'sessão';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: CalendarioConstants.mobileTextColor,
            ),
          ),
          const SizedBox(height: 16),
          _StatRow(
            label: weekLabel, 
            value: weekLessons.toString(),
            valueColor: CalendarioConstants.mobileTextColor,
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Tarefas pendentes',
            value: pendingTasks.toString(),
            valueColor: CalendarioConstants.mobileTextColor,
          ),
          const SizedBox(height: 12),
          _StatRow(
            label: 'Próxima $nextItemLabel em', 
            value: nextLessonLabel,
            valueColor: CalendarioConstants.mobileTextColor,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: CalendarioConstants.mobileStatLabelStyle,
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}