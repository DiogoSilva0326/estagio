import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class CalendarioSemanalContentSection extends StatelessWidget {
  const CalendarioSemanalContentSection({super.key});

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
                _WeeklyTabs(
                  onUpcomingTap: () => Navigator.of(context).pushNamed(Routes.calendario),
                ),
                const SizedBox(height: 22.404),
                const _WeeklyCalendarCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyTabs extends StatelessWidget {
  const _WeeklyTabs({required this.onUpcomingTap});

  final VoidCallback onUpcomingTap;

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
            InkWell(
              onTap: onUpcomingTap,
              child: SizedBox(
                width: 223.837,
                height: 70.014,
                child: Center(
                  child: Text(
                    'Próximas Aulas',
                    style: const TextStyle(
                      fontSize: 22.404,
                      fontWeight: FontWeight.w500,
                      color: CalendarioConstants.inactiveTabColor,
                      height: 33.607 / 22.404,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 22.404),
            SizedBox(
              width: 268.154,
              height: 70.014,
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Calendário Semanal',
                      style: TextStyle(
                        fontSize: 22.404,
                        fontWeight: FontWeight.w500,
                        color: CalendarioConstants.activeTabColor,
                        height: 33.607 / 22.404,
                      ),
                    ),
                  ),
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
          ],
        ),
      ),
    );
  }
}

class _WeeklyCalendarCard extends StatelessWidget {
  const _WeeklyCalendarCard();

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final cardHeight = (viewportHeight - 320).clamp(420.0, 720.0);

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(CalendarioConstants.cardRadius),
          border: Border.all(color: CalendarioConstants.cardBorderColor, width: CalendarioConstants.cardBorderWidth),
          boxShadow: CalendarioConstants.cardShadow,
        ),
        child: const _WeeklyCalendarGrid(),
      ),
    );
  }
}

class _WeeklyCalendarGrid extends StatelessWidget {
  const _WeeklyCalendarGrid();

  static const _headerTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color(0xFF101828),
  );

  static const _subHeaderTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Color(0xFF6A7282),
  );

  @override
  Widget build(BuildContext context) {
    final days = const [
      ('Seg', '19 Fev'),
      ('Ter', '20 Fev'),
      ('Qua', '21 Fev'),
      ('Qui', '22 Fev'),
      ('Sex', '23 Fev'),
      ('Sáb', '24 Fev'),
      ('Dom', '25 Fev'),
    ];

    final hours = List.generate(12, (i) => 8 + i); // 08:00..19:00

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Semana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Row(
              children: const [
                Icon(Icons.chevron_left),
                SizedBox(width: 8),
                Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const SizedBox(width: 52),
            ...days.map(
              (d) => Expanded(
                child: Column(
                  children: [
                    Text(d.$1, style: _headerTextStyle),
                    const SizedBox(height: 2),
                    Text(d.$2, style: _subHeaderTextStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  children: hours.map((h) {
                    return SizedBox(
                      height: 56,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 52,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${h.toString().padLeft(2, '0')}:00',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6A7282),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(7, (dayIndex) {
                            final isLesson = (dayIndex == 0 && h == 14) || (dayIndex == 2 && h == 10);

                            return Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: isLesson ? const Color(0xFFFFF7ED) : const Color(0xFFF9F9F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isLesson ? const Color(0xFFFF6B00) : const Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                child: isLesson
                                    ? const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          'Aula',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF101828),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
