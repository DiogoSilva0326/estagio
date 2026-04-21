import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:flutter/material.dart';

enum CalendarioMode { upcoming, weekly }

class CalendarioModeTabs extends StatelessWidget {
  const CalendarioModeTabs({
    super.key,
    required this.activeMode,
    required this.onUpcomingTap,
    required this.onWeeklyTap,
    required this.isMobile,
  });

  final CalendarioMode activeMode;
  final VoidCallback onUpcomingTap;
  final VoidCallback onWeeklyTap;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Row(
        children: [
          Expanded(
            child: _MobileTabButton(
              label: 'Próximas Aulas',
              selected: activeMode == CalendarioMode.upcoming,
              onTap: onUpcomingTap,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MobileTabButton(
              label: 'Calendário Semanal',
              selected: activeMode == CalendarioMode.weekly,
              onTap: onWeeklyTap,
            ),
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CalendarioConstants.dividerColor,
            width: 1.4,
          ),
        ),
      ),
      child: SizedBox(
        height: 71.414,
        child: Row(
          children: [
            _DesktopTabItem(
              width: 223.837,
              text: 'Próximas Aulas',
              selected: activeMode == CalendarioMode.upcoming,
              onTap: onUpcomingTap,
            ),
            const SizedBox(width: 22.404),
            _DesktopTabItem(
              width: 268.154,
              text: 'Calendário Semanal',
              selected: activeMode == CalendarioMode.weekly,
              onTap: onWeeklyTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileTabButton extends StatelessWidget {
  const _MobileTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? CalendarioConstants.activeTabColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? CalendarioConstants.activeTabColor
                : CalendarioConstants.mobileBorderColor,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? Colors.white
                        : CalendarioConstants.mobileTextColor,
                    height: 20 / 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopTabItem extends StatelessWidget {
  const _DesktopTabItem({
    required this.width,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final double width;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: 70.014,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.404,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? CalendarioConstants.activeTabColor
                      : CalendarioConstants.inactiveTabColor,
                  height: 33.607 / 22.404,
                ),
              ),
            ),
            if (selected)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 2.801,
                  child: ColoredBox(color: CalendarioConstants.activeTabColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
