import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class CalendarioContentSection extends StatelessWidget {
  const CalendarioContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CalendarioConstants.horizontalPadding,
        vertical: CalendarioConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(selectedIndex: 2),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Calendário',
                  style: CalendarioConstants.titleStyle,
                ),
                const SizedBox(height: 11.202),
                const Text(
                  'Organize suas aulas e compromissos',
                  style: CalendarioConstants.subtitleStyle,
                ),
                const SizedBox(height: 33.607),
                _CalendarTabs(
                  onWeeklyTap: () => Navigator.of(context).pushNamed(Routes.calendarioSemanal),
                ),
                const SizedBox(height: 22.404),
                const _UpcomingLessonCard(
                  accentColor: Color(0xFF2B7FFF),
                  subject: 'Matemática',
                  teacherName: 'João Silva',
                  statusLabel: 'Em 5 minutos',
                  statusBackgroundColor: Color(0xFFDCFCE7),
                  statusTextColor: Color(0xFF008236),
                  dateLabel: '📅 Hoje',
                  timeLabel: '🕐 14:30 - 15:30',
                  primaryActionStyle: _PrimaryActionStyle.enterClass,
                  primaryActionLabel: 'Entrar na Aula',
                ),
                const SizedBox(height: 22.404),
                const _UpcomingLessonCard(
                  accentColor: Color(0xFF00C950),
                  subject: 'Física',
                  teacherName: 'Maria Santos',
                  dateLabel: '📅 Amanhã',
                  timeLabel: '🕐 10:00 - 11:00',
                  primaryActionStyle: _PrimaryActionStyle.viewDetails,
                  primaryActionLabel: 'Ver Detalhes',
                ),
                const SizedBox(height: 22.404),
                const _UpcomingLessonCard(
                  accentColor: Color(0xFFFF6900),
                  subject: 'Inglês',
                  teacherName: 'Pedro Costa',
                  dateLabel: '📅 29 Jan',
                  timeLabel: '🕐 16:00 - 17:00',
                  primaryActionStyle: _PrimaryActionStyle.viewDetails,
                  primaryActionLabel: 'Ver Detalhes',
                ),
                const SizedBox(height: 22.404),
                const _UpcomingLessonCard(
                  accentColor: Color(0xFF2B7FFF),
                  subject: 'Matemática',
                  teacherName: 'Ana Rodrigues',
                  dateLabel: '📅 30 Jan',
                  timeLabel: '🕐 15:00 - 16:00',
                  primaryActionStyle: _PrimaryActionStyle.viewDetails,
                  primaryActionLabel: 'Ver Detalhes',
                ),
                const SizedBox(height: 22.404),
                const _NewLessonButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarTabs extends StatelessWidget {
  const _CalendarTabs({required this.onWeeklyTap});

  final VoidCallback onWeeklyTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CalendarioConstants.dividerColor, width: 1.4)),
      ),
      child: SizedBox(
        height: 71.414,
        child: Row(
          children: [
            _TabItem(
              width: 223.837,
              text: 'Próximas Aulas',
              selected: true,
              onTap: () {},
            ),
            const SizedBox(width: 22.404),
            _TabItem(
              width: 268.154,
              text: 'Calendário Semanal',
              selected: false,
              onTap: onWeeklyTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
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
                  color: selected ? CalendarioConstants.activeTabColor : CalendarioConstants.inactiveTabColor,
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

enum _PrimaryActionStyle {
  enterClass,
  viewDetails,
}

class _UpcomingLessonCard extends StatelessWidget {
  const _UpcomingLessonCard({
    required this.accentColor,
    required this.subject,
    required this.teacherName,
    this.statusLabel,
    this.statusBackgroundColor,
    this.statusTextColor,
    required this.dateLabel,
    required this.timeLabel,
    required this.primaryActionStyle,
    required this.primaryActionLabel,
  });

  final Color accentColor;
  final String subject;
  final String teacherName;

  final String? statusLabel;
  final Color? statusBackgroundColor;
  final Color? statusTextColor;

  final String dateLabel;
  final String timeLabel;

  final _PrimaryActionStyle primaryActionStyle;
  final String primaryActionLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 254.851,
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 35.007, vertical: 35.007),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CalendarioConstants.cardRadius),
          border: Border.all(color: CalendarioConstants.cardBorderColor, width: CalendarioConstants.cardBorderWidth),
          boxShadow: CalendarioConstants.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 11.202,
              height: 89.618,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(23492794),
              ),
            ),
            const SizedBox(width: 22.404),
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
                              style: const TextStyle(
                                fontSize: 25.205,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF101828),
                                height: 39.208 / 25.205,
                              ),
                            ),
                            Text(
                              'com $teacherName',
                              style: const TextStyle(
                                fontSize: 19.604,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF4A5565),
                                height: 28.006 / 19.604,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (statusLabel != null && statusBackgroundColor != null && statusTextColor != null)
                        Container(
                          height: 33.607,
                          padding: const EdgeInsets.symmetric(horizontal: 16.803),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: statusBackgroundColor,
                            borderRadius: BorderRadius.circular(23492794),
                          ),
                          child: Text(
                            statusLabel!,
                            style: TextStyle(
                              fontSize: 16.803,
                              fontWeight: FontWeight.w500,
                              color: statusTextColor,
                              height: 22.404 / 16.803,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 11.202),
                  Row(
                    children: [
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 19.604,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A5565),
                          height: 28.006 / 19.604,
                        ),
                      ),
                      const SizedBox(width: 33.607),
                      Flexible(
                        child: Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 19.604,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4A5565),
                            height: 28.006 / 19.604,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _PrimaryActionButton(
                        style: primaryActionStyle,
                        label: primaryActionLabel,
                      ),
                      const SizedBox(width: 16.803),
                      const _SecondaryIconButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.style,
    required this.label,
  });

  final _PrimaryActionStyle style;
  final String label;

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      _PrimaryActionStyle.enterClass => SizedBox(
          width: 240.345,
          height: 56.011,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C950),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(19.604),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 33.607,
                  top: (56.011 - 22.404) / 2,
                  child: Icon(Icons.play_arrow_rounded, size: 22.404, color: Colors.white),
                ),
                Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 22.404,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 33.607 / 22.404,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      _PrimaryActionStyle.viewDetails => _GradientButton(
          width: 193.359,
          height: 56.011,
          radius: 19.604,
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 22.404,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 33.607 / 22.404,
              ),
            ),
          ),
        ),
    };
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.width,
    required this.height,
    required this.radius,
    required this.child,
  });

  final double width;
  final double height;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF6B00),
                Color(0xFFFF9966),
              ],
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(radius),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SecondaryIconButton extends StatelessWidget {
  const _SecondaryIconButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70.014,
      height: 56.011,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: Color(0xFFFFC9C9), width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19.604)),
        ),
        child: const Icon(Icons.close_rounded, size: 22.404, color: Color(0xFFFB2C36)),
      ),
    );
  }
}

class _NewLessonButton extends StatelessWidget {
  const _NewLessonButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 84.017,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add_circle_outline_rounded, size: 28.006, color: Color(0xFF4A5565)),
        label: const Text(
          'Marcar Nova Aula',
          style: TextStyle(
            fontSize: 22.404,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4A5565),
            height: 33.607 / 22.404,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(2.801),
          side: const BorderSide(color: Color(0xFFD1D5DC), width: 2.801),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.404)),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
