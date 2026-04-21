import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:flutter/material.dart';

class MobileUpcomingLessonCard extends StatelessWidget {
  const MobileUpcomingLessonCard({
    super.key,
    required this.accentColor,
    required this.subject,
    required this.teacherName,
    required this.dateLabel,
    required this.timeLabel,
    required this.primaryLabel,
    required this.onPrimaryTap,
    this.onSecondaryTap,
    this.primaryGradient,
    this.primaryBackgroundColor,
    this.primaryForegroundColor = Colors.white,
    this.statusLabel,
    this.statusBackgroundColor,
    this.statusTextColor,
    this.secondaryIsLoading = false,
    this.showPlayIcon = false,
  });

  final Color accentColor;
  final String subject;
  final String teacherName;
  final String dateLabel;
  final String timeLabel;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;
  final Gradient? primaryGradient;
  final Color? primaryBackgroundColor;
  final Color primaryForegroundColor;
  final String? statusLabel;
  final Color? statusBackgroundColor;
  final Color? statusTextColor;
  final bool secondaryIsLoading;
  final bool showPlayIcon;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 96,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
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
                            style: CalendarioConstants.mobileCardTitleStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'com $teacherName',
                            style: CalendarioConstants.mobileCardSubtitleStyle,
                          ),
                        ],
                      ),
                    ),
                    if (statusLabel != null &&
                        statusBackgroundColor != null &&
                        statusTextColor != null)
                      Container(
                        margin: const EdgeInsets.only(left: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusBackgroundColor,
                          borderRadius: BorderRadius.circular(
                            CalendarioConstants.mobileChipRadius,
                          ),
                        ),
                        child: Text(
                          statusLabel!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusTextColor,
                            height: 16 / 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: dateLabel,
                    ),
                    _MetaChip(icon: Icons.schedule_rounded, label: timeLabel),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _PrimaryButton(
                        label: primaryLabel,
                        onTap: onPrimaryTap,
                        gradient: primaryGradient,
                        backgroundColor: primaryBackgroundColor,
                        foregroundColor: primaryForegroundColor,
                        showPlayIcon: showPlayIcon,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _SecondaryButton(
                      onTap: onSecondaryTap,
                      isLoading: secondaryIsLoading,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: CalendarioConstants.mobileMutedColor),
        const SizedBox(width: 6),
        Text(label, style: CalendarioConstants.mobileMetaStyle),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.gradient,
    this.backgroundColor,
    required this.foregroundColor,
    required this.showPlayIcon,
  });

  final String label;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color foregroundColor;
  final bool showPlayIcon;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: gradient == null
          ? (backgroundColor ?? CalendarioConstants.activeTabColor)
          : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(
        CalendarioConstants.mobilePrimaryButtonRadius,
      ),
    );

    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              CalendarioConstants.mobilePrimaryButtonRadius,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showPlayIcon) ...[
                  Icon(
                    Icons.play_arrow_rounded,
                    color: foregroundColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: foregroundColor,
                      height: 22 / 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.onTap, required this.isLoading});

  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: isLoading ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0xFFFFD5D8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              CalendarioConstants.mobileSecondaryButtonRadius,
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(
                Icons.close_rounded,
                color: CalendarioConstants.mobileDangerColor,
                size: 20,
              ),
      ),
    );
  }
}
