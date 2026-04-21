import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:flutter/material.dart';

class MobileWeekHeader extends StatelessWidget {
  const MobileWeekHeader({
    super.key,
    required this.label,
    required this.onPreviousTap,
    required this.onNextTap,
  });

  final String label;
  final VoidCallback onPreviousTap;
  final VoidCallback onNextTap;

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
      ),
      child: Row(
        children: [
          _WeekArrowButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPreviousTap,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: CalendarioConstants.mobileTextColor,
                height: 24 / 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _WeekArrowButton(icon: Icons.chevron_right_rounded, onTap: onNextTap),
        ],
      ),
    );
  }
}

class _WeekArrowButton extends StatelessWidget {
  const _WeekArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: CalendarioConstants.mobileSoftSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CalendarioConstants.mobileBorderColor),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Icon(icon, color: CalendarioConstants.mobileTextColor),
          ),
        ),
      ),
    );
  }
}
