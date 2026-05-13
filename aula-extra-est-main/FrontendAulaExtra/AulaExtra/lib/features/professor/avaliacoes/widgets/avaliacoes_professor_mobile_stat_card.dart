import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';

class AvaliacoesProfessorMobileStatCard extends StatelessWidget {
  const AvaliacoesProfessorMobileStatCard({
    super.key,
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    final isOrange = config.roleName == 'Explicador';

    return Container(
      width: double.infinity,
      height: AvaliacoesProfessorLayout.mobileSummaryCardHeight,
      decoration: BoxDecoration(
        color: isOrange ? null : config.primaryColor,
        gradient: isOrange ? const LinearGradient(
          begin: Alignment(0.50, 0.00),
          end: Alignment(0.50, 1.00),
          colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
        ) : null,
        borderRadius: BorderRadius.circular(
          AvaliacoesProfessorLayout.mobileSummaryCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 7.22,
            offset: Offset(0, 4.81),
            spreadRadius: -4.81,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 18.04,
            offset: Offset(0, 12.03),
            spreadRadius: -3.61,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: AvaliacoesProfessorLayout.mobileSummaryIconSize,
                ),
                const SizedBox(width: 6.59),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize:
                        AvaliacoesProfessorLayout.mobileSummaryValueFontSize,
                    fontFamily: 'Helvetica Neue',
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.59),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AvaliacoesProfessorLayout.mobileSummaryLabelFontSize,
                fontFamily: 'Helvetica Neue',
                fontWeight: FontWeight.w400,
                height: 1.56,
              ),
            ),
          ],
        ),
      ),
    );
  }
}