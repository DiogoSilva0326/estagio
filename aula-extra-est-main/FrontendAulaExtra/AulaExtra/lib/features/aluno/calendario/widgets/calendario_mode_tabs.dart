import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/core/providers/user_provider.dart'; 
import 'package:aula_extra/core/config/teaching_roles_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    final isStudent = userProvider.role == Role.student;
    
    final upcomingLabel = isStudent ? 'Próximas Sessões' : config.calendario.nextSessionLabel;
    
    final Color activeColor = (isStudent || config.roleName == 'Explicador') 
        ? CalendarioConstants.activeTabColor 
        : config.primaryColor;

    if (isMobile) {
      return Row(
        children: [
          Expanded(
            child: _MobileTabButton(
              label: upcomingLabel,
              selected: activeMode == CalendarioMode.upcoming,
              onTap: onUpcomingTap,
              activeColor: activeColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MobileTabButton(
              label: 'Calendário Semanal',
              selected: activeMode == CalendarioMode.weekly,
              onTap: onWeeklyTap,
              activeColor: activeColor,
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
              text: upcomingLabel,
              selected: activeMode == CalendarioMode.upcoming,
              onTap: onUpcomingTap,
              activeColor: activeColor,
            ),
            const SizedBox(width: 22.404),
            _DesktopTabItem(
              width: 268.154,
              text: 'Calendário Semanal',
              selected: activeMode == CalendarioMode.weekly,
              onTap: onWeeklyTap,
              activeColor: activeColor,
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
    required this.activeColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? activeColor
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
    required this.activeColor,
  });

  final double width;
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final Color activeColor;

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
                      ? activeColor
                      : CalendarioConstants.inactiveTabColor,
                  height: 33.607 / 22.404,
                ),
              ),
            ),
            if (selected)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 2.801,
                  child: ColoredBox(color: activeColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}