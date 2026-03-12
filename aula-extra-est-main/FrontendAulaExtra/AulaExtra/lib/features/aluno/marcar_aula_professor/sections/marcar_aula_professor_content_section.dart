import 'package:aula_extra/features/aluno/marcar_aula_professor/constants/marcar_aula_professor_constants.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/models/marcar_aula_professor_args.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class MarcarAulaProfessorContentSection extends StatefulWidget {
  const MarcarAulaProfessorContentSection({
    super.key,
    required this.args,
  });

  final MarcarAulaProfessorArgs args;

  @override
  State<MarcarAulaProfessorContentSection> createState() => _MarcarAulaProfessorContentSectionState();
}

enum _LessonType {
  experimental,
  individual,
  pack5,
  pack10,
}

class _LessonTypeInfo {
  const _LessonTypeInfo({
    required this.type,
    required this.title,
    required this.durationText,
    required this.priceText,
    this.badgeText,
    this.priceHintText,
  });

  final _LessonType type;
  final String title;
  final String durationText;
  final String priceText;
  final String? badgeText;
  final String? priceHintText;
}

class _SelectedSlot {
  const _SelectedSlot({
    required this.date,
    required this.timeLabel,
  });

  final DateTime date;
  final String timeLabel;
}

class _MarcarAulaProfessorContentSectionState extends State<MarcarAulaProfessorContentSection> {
  _LessonType _selectedLessonType = _LessonType.individual;
  _SelectedSlot? _selectedSlot;

  late DateTime _weekStart;

  static const List<String> _dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  static const List<String> _timeLabels = [
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
    '23:30',
  ];

  static const List<_LessonTypeInfo> _lessonTypes = [
    _LessonTypeInfo(
      type: _LessonType.experimental,
      title: 'Aula Experimental',
      durationText: '30 minutos',
      priceText: '15€',
    ),
    _LessonTypeInfo(
      type: _LessonType.individual,
      title: 'Aula Individual',
      durationText: '60 minutos',
      priceText: '25€',
    ),
    _LessonTypeInfo(
      type: _LessonType.pack5,
      title: 'Pacote 5 Aulas',
      durationText: '60 minutos × 5',
      priceText: '110€',
      badgeText: '-10%',
      priceHintText: '(22€/aula)',
    ),
    _LessonTypeInfo(
      type: _LessonType.pack10,
      title: 'Pacote 10 Aulas',
      durationText: '60 minutos × 10',
      priceText: '200€',
      badgeText: '-20%',
      priceHintText: '(20€/aula)',
    ),
  ];

  static const List<String> _monthShortPt = [
    'jan.',
    'fev.',
    'mar.',
    'abr.',
    'mai.',
    'jun.',
    'jul.',
    'ago.',
    'set.',
    'out.',
    'nov.',
    'dez.',
  ];

  @override
  void initState() {
    super.initState();
    _weekStart = _startOfWeek(DateTime.now());
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static DateTime _startOfWeek(DateTime dt) {
    final d = _dateOnly(dt);
    // Monday = 1 ... Sunday = 7
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  String _formatWeekRange(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final startMonth = _monthShortPt[weekStart.month - 1];
    final endMonth = _monthShortPt[weekEnd.month - 1];

    if (weekStart.month == weekEnd.month) {
      return '${weekStart.day} - ${weekEnd.day} $startMonth';
    }
    return '${weekStart.day} $startMonth - ${weekEnd.day} $endMonth';
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MarcarAulaProfessorConstants.horizontalPadding,
        vertical: MarcarAulaProfessorConstants.verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(
            tutorName: args.tutorName,
            onBackTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final showSideSummary = constraints.maxWidth >= 860;

              final left = _LeftColumn(
                args: args,
                selectedLessonType: _selectedLessonType,
                selectedSlot: _selectedSlot,
                weekStart: _weekStart,
                weekLabel: _formatWeekRange(_weekStart),
                onPrevWeekTap: () => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7))),
                onNextWeekTap: () => setState(() => _weekStart = _weekStart.add(const Duration(days: 7))),
                onViewProfileTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.tutorProfile,
                    arguments: TutorProfileArgs(
                      name: args.tutorName,
                      country: 'Portugal',
                      rating: args.rating,
                      reviewCount: args.reviewCount,
                      description:
                          'Sou ${args.tutorName}, um explicador apaixonado por ensinar e ajudar alunos a alcançarem os seus objetivos.',
                      lessonsText: '—',
                      pricePerHour: args.pricePerHour,
                      tags: [args.subject],
                    ),
                  );
                },
                onLessonTypeSelected: (type) => setState(() => _selectedLessonType = type),
                onSlotSelected: (slot) => setState(() => _selectedSlot = slot),
              );

              final summary = _SummaryCard(
                args: args,
                selectedLessonType: _selectedLessonType,
                selectedSlot: _selectedSlot,
                onConfirmTap: _selectedSlot == null ? null : () {},
              );

              if (!showSideSummary) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    left,
                    const SizedBox(height: 24),
                    summary,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 32),
                  SizedBox(
                    width: 400,
                    child: summary,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.tutorName,
    required this.onBackTap,
  });

  final String tutorName;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MarcarAulaProfessorConstants.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SizedBox(
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onBackTap,
                  icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4A5565)),
                  label: const Text(
                    'Voltar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4A5565),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 84),
                child: Text.rich(
                  TextSpan(
                    text: 'Marcar Aula com ',
                    style: MarcarAulaProfessorConstants.topBarTitleStyle,
                    children: [
                      TextSpan(
                        text: tutorName,
                        style: MarcarAulaProfessorConstants.topBarTutorNameStyle,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: MarcarAulaProfessorConstants.orangeGradient,
                  ),
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Text(
                        'E',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn({
    required this.args,
    required this.selectedLessonType,
    required this.selectedSlot,
    required this.weekStart,
    required this.weekLabel,
    required this.onPrevWeekTap,
    required this.onNextWeekTap,
    required this.onViewProfileTap,
    required this.onLessonTypeSelected,
    required this.onSlotSelected,
  });

  final MarcarAulaProfessorArgs args;
  final _LessonType selectedLessonType;
  final _SelectedSlot? selectedSlot;
  final DateTime weekStart;
  final String weekLabel;
  final VoidCallback onPrevWeekTap;
  final VoidCallback onNextWeekTap;
  final VoidCallback onViewProfileTap;
  final ValueChanged<_LessonType> onLessonTypeSelected;
  final ValueChanged<_SelectedSlot> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TutorSummaryCard(
          args: args,
          onViewProfileTap: onViewProfileTap,
        ),
        const SizedBox(height: 24),
        _SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Escolha o tipo de aula', style: MarcarAulaProfessorConstants.sectionTitleStyle),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 720;
                  final spacing = isNarrow ? 12.0 : 16.0;

                  Widget buildCard(_LessonTypeInfo info) {
                    final isSelected = info.type == selectedLessonType;
                    return _LessonTypeCard(
                      info: info,
                      isSelected: isSelected,
                      onTap: () => onLessonTypeSelected(info.type),
                    );
                  }

                  if (isNarrow) {
                    return Column(
                      children: [
                        buildCard(_MarcarAulaProfessorContentSectionState._lessonTypes[0]),
                        SizedBox(height: spacing),
                        buildCard(_MarcarAulaProfessorContentSectionState._lessonTypes[1]),
                        SizedBox(height: spacing),
                        buildCard(_MarcarAulaProfessorContentSectionState._lessonTypes[2]),
                        SizedBox(height: spacing),
                        buildCard(_MarcarAulaProfessorContentSectionState._lessonTypes[3]),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            buildCard(_MarcarAulaProfessorContentSectionState._lessonTypes[0]),
                            SizedBox(height: spacing),
                            buildCard(_MarcarAulaProfessorContentSectionState._lessonTypes[2]),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing),
                      Expanded(
                        child: Column(
                          children: [
                            buildCard(_MarcarAulaProfessorContentSectionState._lessonTypes[1]),
                            SizedBox(height: spacing),
                            buildCard(_MarcarAulaProfessorContentSectionState._lessonTypes[3]),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionCard(
          child: _ScheduleSection(
            selectedSlot: selectedSlot,
            weekStart: weekStart,
            weekLabel: weekLabel,
            onPrevWeekTap: onPrevWeekTap,
            onNextWeekTap: onNextWeekTap,
            onSlotSelected: onSlotSelected,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MarcarAulaProfessorConstants.borderSoft),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({
    required this.selectedSlot,
    required this.weekStart,
    required this.weekLabel,
    required this.onPrevWeekTap,
    required this.onNextWeekTap,
    required this.onSlotSelected,
  });

  final _SelectedSlot? selectedSlot;
  final DateTime weekStart;
  final String weekLabel;
  final VoidCallback onPrevWeekTap;
  final VoidCallback onNextWeekTap;
  final ValueChanged<_SelectedSlot> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Escolha data e horário', style: MarcarAulaProfessorConstants.sectionTitleStyle),
            ),
            IconButton(
              onPressed: onPrevWeekTap,
              icon: const Icon(Icons.chevron_left_rounded, color: Color(0xFF4A5565)),
              tooltip: 'Semana anterior',
            ),
            Text(
              weekLabel,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A5565)),
            ),
            IconButton(
              onPressed: onNextWeekTap,
              icon: const Icon(Icons.chevron_right_rounded, color: Color(0xFF4A5565)),
              tooltip: 'Próxima semana',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TimeSlotTable(
          weekStart: weekStart,
          selectedSlot: selectedSlot,
          onSlotSelected: onSlotSelected,
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Icon(Icons.info_outline, size: 18, color: MarcarAulaProfessorConstants.textMuted),
            SizedBox(width: 8),
            Text(
              '15 minutos de intervalo entre aulas para preparação',
              style: TextStyle(fontSize: 14, color: MarcarAulaProfessorConstants.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}

class _TutorSummaryCard extends StatelessWidget {
  const _TutorSummaryCard({
    required this.args,
    required this.onViewProfileTap,
  });

  final MarcarAulaProfessorArgs args;
  final VoidCallback onViewProfileTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MarcarAulaProfessorConstants.borderSoft),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: MarcarAulaProfessorConstants.orange,
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: MarcarAulaProfessorConstants.textMuted),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                args.tutorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: MarcarAulaProfessorConstants.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: MarcarAulaProfessorConstants.blue,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                args.subject.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: onViewProfileTap,
                        child: const Text('Ver Perfil', style: MarcarAulaProfessorConstants.linkStyle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 20, color: MarcarAulaProfessorConstants.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        args.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF4A5565),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${args.reviewCount} avaliações)',
                        style: const TextStyle(fontSize: 14, color: MarcarAulaProfessorConstants.textSubtle),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF4A5565)),
                      const SizedBox(width: 6),
                      Text(
                        args.location,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text(
                        'A partir de ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: MarcarAulaProfessorConstants.textDark),
                      ),
                      Text(
                        '${args.pricePerHour}€/hora',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: MarcarAulaProfessorConstants.orange),
                      ),
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

class _LessonTypeCard extends StatelessWidget {
  const _LessonTypeCard({
    required this.info,
    required this.isSelected,
    required this.onTap,
  });

  final _LessonTypeInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? MarcarAulaProfessorConstants.orange : MarcarAulaProfessorConstants.lessonTypeBorder;
    final bgColor = isSelected ? const Color(0xFFFFF7ED) : Colors.white;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        info.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MarcarAulaProfessorConstants.textDark,
                        ),
                      ),
                    ),
                    if (info.badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: MarcarAulaProfessorConstants.greenSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          info.badgeText!,
                          style: const TextStyle(
                            color: MarcarAulaProfessorConstants.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Color(0xFF4A5565)),
                    const SizedBox(width: 6),
                    Text(
                      info.durationText,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      info.priceText,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: MarcarAulaProfessorConstants.orange,
                      ),
                    ),
                    if (info.priceHintText != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        info.priceHintText!,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF6A7282)),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeSlotTable extends StatelessWidget {
  const _TimeSlotTable({
    required this.weekStart,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  final DateTime weekStart;
  final _SelectedSlot? selectedSlot;
  final ValueChanged<_SelectedSlot> onSlotSelected;

  bool _isAvailable(int dayIndex, int timeIndex) {
    // Static pattern similar to the Figma grid: some slots available (✓) and others unavailable (—).
    if (dayIndex >= 5) return timeIndex.isEven;
    if (dayIndex == 0) return timeIndex % 3 != 2;
    if (dayIndex == 1) return timeIndex % 2 == 0;
    if (dayIndex == 2) return timeIndex % 4 != 0;
    if (dayIndex == 3) return timeIndex % 3 == 0;
    return timeIndex % 5 != 1;
  }

  @override
  Widget build(BuildContext context) {
    final dayLabels = _MarcarAulaProfessorContentSectionState._dayLabels;
    final timeLabels = _MarcarAulaProfessorContentSectionState._timeLabels;

    DateTime dateForIndex(int index) => DateTime(weekStart.year, weekStart.month, weekStart.day).add(Duration(days: index));

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: MarcarAulaProfessorConstants.borderSoft),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 92),
                    for (var dayIndex = 0; dayIndex < dayLabels.length; dayIndex++)
                      SizedBox(
                        width: 92,
                        child: Column(
                          children: [
                            Text(
                              dayLabels[dayIndex],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: MarcarAulaProfessorConstants.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _DayPill(
                              day: dateForIndex(dayIndex),
                              isSelected: selectedSlot != null &&
                                  DateTime(selectedSlot!.date.year, selectedSlot!.date.month, selectedSlot!.date.day) ==
                                      DateTime(dateForIndex(dayIndex).year, dateForIndex(dayIndex).month, dateForIndex(dayIndex).day),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                for (var timeIndex = 0; timeIndex < timeLabels.length; timeIndex++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 92,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              timeLabels[timeIndex],
                              style: const TextStyle(fontSize: 14, color: MarcarAulaProfessorConstants.textMuted),
                            ),
                          ),
                        ),
                        for (var dayIndex = 0; dayIndex < dayLabels.length; dayIndex++)
                          _TimeSlotCell(
                            width: 92,
                            isAvailable: _isAvailable(dayIndex, timeIndex),
                            isSelected: selectedSlot != null &&
                                DateTime(selectedSlot!.date.year, selectedSlot!.date.month, selectedSlot!.date.day) ==
                                    DateTime(dateForIndex(dayIndex).year, dateForIndex(dayIndex).month, dateForIndex(dayIndex).day) &&
                                selectedSlot!.timeLabel == timeLabels[timeIndex],
                            onTap: () {
                              if (!_isAvailable(dayIndex, timeIndex)) return;
                              onSlotSelected(
                                _SelectedSlot(
                                  date: dateForIndex(dayIndex),
                                  timeLabel: timeLabels[timeIndex],
                                ),
                              );
                            },
                          ),
                      ],
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

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.day,
    required this.isSelected,
  });

  final DateTime day;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isSelected ? MarcarAulaProfessorConstants.orange : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : const Color(0xFF4A5565),
        ),
      ),
    );
  }
}

class _TimeSlotCell extends StatelessWidget {
  const _TimeSlotCell({
    required this.width,
    required this.isAvailable,
    required this.isSelected,
    required this.onTap,
  });

  final double width;
  final bool isAvailable;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isAvailable ? MarcarAulaProfessorConstants.greenSoft : const Color(0xFFF3F4F6);
    final fg = isAvailable ? MarcarAulaProfessorConstants.green : MarcarAulaProfessorConstants.textSubtle;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            height: 44,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: MarcarAulaProfessorConstants.orange, width: 2) : null,
            ),
            child: Center(
              child: Text(
                isAvailable ? '✓' : '—',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: fg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.args,
    required this.selectedLessonType,
    required this.selectedSlot,
    required this.onConfirmTap,
  });

  final MarcarAulaProfessorArgs args;
  final _LessonType selectedLessonType;
  final _SelectedSlot? selectedSlot;
  final VoidCallback? onConfirmTap;

  _LessonTypeInfo get _lessonInfo => _MarcarAulaProfessorContentSectionState._lessonTypes
      .firstWhere((element) => element.type == selectedLessonType);

  @override
  Widget build(BuildContext context) {
    final lessonInfo = _lessonInfo;

    String formatSelectedDate(_SelectedSlot slot) {
      const monthShort = _MarcarAulaProfessorContentSectionState._monthShortPt;
      final m = monthShort[slot.date.month - 1];
      return '${slot.date.day} $m às ${slot.timeLabel}';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MarcarAulaProfessorConstants.borderSoft),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Resumo da Reserva', style: MarcarAulaProfessorConstants.sectionTitleStyle),
            const SizedBox(height: 16),
            Divider(color: MarcarAulaProfessorConstants.borderSoft, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: MarcarAulaProfessorConstants.orange,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: MarcarAulaProfessorConstants.textMuted, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      args.tutorName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: MarcarAulaProfessorConstants.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      args.subject,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              icon: Icons.event_available,
              label: 'DATA E HORA',
              value: selectedSlot == null ? 'Selecione um horário' : formatSelectedDate(selectedSlot!),
              isMuted: selectedSlot == null,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              icon: Icons.schedule,
              label: 'DURAÇÃO',
              value: lessonInfo.durationText.contains('×') ? '60 minutos' : lessonInfo.durationText,
              isMuted: false,
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFEDD4)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF7ED), Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(fontSize: 14, color: Color(0xFF4A5565))),
                        Text(lessonInfo.priceText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFFFD6A7), height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        Text(
                          lessonInfo.priceText,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: MarcarAulaProfessorConstants.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Aceito os ', style: TextStyle(color: Color(0xFF4A5565), fontSize: 14)),
                  TextSpan(text: 'Termos de Serviço', style: TextStyle(color: MarcarAulaProfessorConstants.orangeSoft, fontSize: 14)),
                  TextSpan(text: ' e a ', style: TextStyle(color: Color(0xFF4A5565), fontSize: 14)),
                  TextSpan(text: 'Política de Cancelamento', style: TextStyle(color: MarcarAulaProfessorConstants.orangeSoft, fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onConfirmTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onConfirmTap == null ? const Color(0xFFD1D5DC) : MarcarAulaProfessorConstants.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirmar e Agendar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: MarcarAulaProfessorConstants.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Pagamento seguro via Stripe',
                    style: TextStyle(fontSize: 12, color: MarcarAulaProfessorConstants.textMuted),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isMuted,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: MarcarAulaProfessorConstants.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.4,
                  color: MarcarAulaProfessorConstants.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isMuted ? MarcarAulaProfessorConstants.textSubtle : MarcarAulaProfessorConstants.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
