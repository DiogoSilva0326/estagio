import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:flutter/material.dart';

class MobileWeekDayCard extends StatelessWidget {
  const MobileWeekDayCard({
    super.key,
    required this.title,
    required this.children,
    this.isToday = false,
  });

  final String title;
  final List<Widget> children;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? CalendarioConstants.mobileTodaySurface
            : CalendarioConstants.mobileSurfaceColor,
        borderRadius: BorderRadius.circular(
          CalendarioConstants.mobileCardRadius,
        ),
        border: Border.all(
          color: isToday
              ? const Color(0xFFFEB273)
              : CalendarioConstants.mobileBorderColor,
        ),
        boxShadow: isToday ? CalendarioConstants.mobileShadow : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isToday
                  ? CalendarioConstants.activeTabColor
                  : CalendarioConstants.mobileTextColor,
              height: 24 / 18,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class MobileWeekLessonTile extends StatelessWidget {
  const MobileWeekLessonTile({
    super.key,
    required this.subject,
    required this.teacher,
    required this.timeRange,
    required this.durationLabel,
    required this.actionLabel,
    required this.onActionTap,
    this.useSuccessButton = false,
  });

  final String subject;
  final String teacher;
  final String timeRange;
  final String durationLabel;
  final String actionLabel;
  final VoidCallback onActionTap;
  final bool useSuccessButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CalendarioConstants.mobileBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: CalendarioConstants.mobileSectionTitleStyle,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      teacher,
                      style: CalendarioConstants.mobileCardSubtitleStyle,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  durationLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CalendarioConstants.mobileMutedColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: CalendarioConstants.mobileMutedColor,
              ),
              const SizedBox(width: 6),
              Text(timeRange, style: CalendarioConstants.mobileMetaStyle),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: useSuccessButton
                    ? CalendarioConstants.mobileSuccessColor
                    : null,
                gradient: useSuccessButton
                    ? null
                    : CalendarioConstants.orangeGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Center(
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 20 / 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileWeekEmptyState extends StatelessWidget {
  const MobileWeekEmptyState({super.key, this.label = 'Sem aulas agendadas'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: CalendarioConstants.mobileSoftSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: CalendarioConstants.mobileCardSubtitleStyle,
      ),
    );
  }
}
