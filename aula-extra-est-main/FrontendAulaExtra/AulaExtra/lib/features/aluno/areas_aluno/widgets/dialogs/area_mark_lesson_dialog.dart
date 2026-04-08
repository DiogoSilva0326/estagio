import 'package:aula_extra/core/data/tutors/dtos/my_tutor_dto.dart';
import 'package:aula_extra/core/data/tutors/my_tutors_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_calendar_item_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_area_summary_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:aula_extra/features/aluno/areas_aluno/models/area_overview.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/models/marcar_aula_professor_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:flutter/material.dart';

Future<void> showAreaMarkLessonDialog(
  BuildContext context, {
  required AreaOverview area,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AreaMarkLessonDialog(area: area),
  );
}

class AreaMarkLessonDialog extends StatefulWidget {
  const AreaMarkLessonDialog({
    super.key,
    required this.area,
  });

  final AreaOverview area;

  @override
  State<AreaMarkLessonDialog> createState() => _AreaMarkLessonDialogState();
}

class _AreaMarkLessonDialogState extends State<AreaMarkLessonDialog> {
  final _myTutorsService = MyTutorsService();
  final _calendarService = ReservationsCalendarService();

  late final Future<_AreaMarkLessonData> _dialogFuture;

  @override
  void initState() {
    super.initState();
    _dialogFuture = _loadDialogData();
  }

  Future<List<MyTutorDto>> _loadTutors() async {
    final areaId = widget.area.idArea.trim();
    if (areaId.isEmpty) return const [];

    try {
      return await _myTutorsService.getMyTutorsByArea(areaId: areaId);
    } catch (_) {
      return const [];
    }
  }

  Future<_AreaMarkLessonData> _loadDialogData() async {
    final tutorsFuture = _loadTutors();

    StudentAreaSummaryDto? summary;
    List<StudentCalendarItemDto> weekItems = const [];
    List<StudentCalendarItemDto> upcomingItems = const [];

    if (widget.area.idArea.trim().isNotEmpty) {
      try {
        summary = await _calendarService.getMyAreaSummary(
          areaId: widget.area.idArea.trim(),
        );
      } catch (_) {}
    }

    try {
      weekItems = await _calendarService.getMyWeek();
    } catch (_) {}

    try {
      upcomingItems = await _calendarService.getMyUpcoming(limit: 20);
    } catch (_) {}

    final tutors = await tutorsFuture;
    final filteredWeekItems = weekItems.where(_matchesAreaLesson).where(_isActiveLesson).toList(growable: false);
    final filteredUpcomingItems = upcomingItems.where(_matchesAreaLesson).where(_isActiveLesson).toList(growable: false);

    final nextLessonStart = summary?.nextLessonStart ??
        (filteredUpcomingItems.isEmpty ? null : filteredUpcomingItems.first.startTime);

    return _AreaMarkLessonData(
      tutors: tutors,
      weeklyLessons: filteredWeekItems.length,
      nextLessonText: _formatLessonMoment(nextLessonStart),
    );
  }

  bool _matchesAreaLesson(StudentCalendarItemDto item) {
    final tokens = <String>{
      widget.area.name.trim().toLowerCase(),
      ...widget.area.selectedDisciplinaNames
          .map((name) => name.trim().toLowerCase())
          .where((name) => name.isNotEmpty),
    }..removeWhere((token) => token.isEmpty);

    if (tokens.isEmpty) return true;

    final disciplina = item.disciplinaName.trim().toLowerCase();
    final title = item.lessonTitle.trim().toLowerCase();

    return tokens.any((token) => disciplina.contains(token) || title.contains(token));
  }

  bool _isActiveLesson(StudentCalendarItemDto item) {
    final status = item.status.trim().toLowerCase();
    if (status.isEmpty) return true;
    return !status.contains('cancel');
  }

  Future<void> _openTutorProfile(MyTutorDto tutor) async {
    Navigator.of(context).pushNamed(
      Routes.tutorProfile,
      arguments: TutorProfileArgs(
        professorId: tutor.professorId,
        name: tutor.tutorName,
        country: 'Portugal',
        rating: tutor.rating ?? 0,
        reviewCount: 0,
        description:
            'Perfil do explicador ${tutor.tutorName} para a área selecionada. Pode ver a informação detalhada antes de marcar a próxima aula.',
        lessonsText: tutor.lastLessonSubject == null || tutor.lastLessonSubject!.trim().isEmpty
            ? 'Sem aulas registadas'
            : 'Última aula: ${tutor.lastLessonSubject!.trim()}',
        pricePerHour: 0,
        tags: widget.area.selectedDisciplinaNames.isEmpty ? [widget.area.name] : widget.area.selectedDisciplinaNames,
      ),
    );
  }

  Future<void> _openScheduleLesson(MyTutorDto tutor) async {
    final subject = tutor.lastLessonSubject?.trim().isNotEmpty == true
        ? tutor.lastLessonSubject!.trim()
        : (widget.area.selectedDisciplinaNames.isNotEmpty
              ? widget.area.selectedDisciplinaNames.first
              : widget.area.name);

    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushNamed(
      Routes.marcarAulaProfessor,
      arguments: MarcarAulaProfessorArgs(
        professorId: tutor.professorId,
        tutorName: tutor.tutorName,
        subject: subject,
        rating: tutor.rating ?? 0,
        reviewCount: 0,
        location: 'Portugal',
        pricePerHour: 0,
      ),
    );
  }

  String _formatLessonMoment(DateTime? value) {
    if (value == null) return 'nenhuma';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(value.year, value.month, value.day);
    final diff = targetDay.difference(today).inDays;
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    if (diff == 0) return 'hoje $hour:$minute';
    if (diff == 1) return 'amanhã $hour:$minute';
    if (diff > 1) return 'em $diff dias';
    return '$hour:$minute';
  }

  static const _dialogRadius = 16.0;

  static const _mutedSurface = Color(0xFFF9FAFB);
  static const _divider = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return FutureBuilder<_AreaMarkLessonData>(
      future: _dialogFuture,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _AreaMarkLessonData();
        final tutors = data.tutors;
        final hasHistory = tutors.isNotEmpty;

        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_dialogRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 896, maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _Header(
                  area: widget.area,
                  tutorCount: tutors.length,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 39, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: LinearProgressIndicator(
                                minHeight: 3,
                                color: Color(0xFFFC9039),
                                backgroundColor: Color(0xFFFFEDD5),
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  borderColor: const Color(0xFFDBEAFE),
                                  gradientStart: const Color(0xFFEFF6FF),
                                  gradientEnd: const Color(0xFFFFFFFF),
                                  icon: Icons.menu_book_outlined,
                                  iconColor: const Color(0xFF155DFC),
                                  title: 'AULAS ESTA SEMANA',
                                  titleColor: const Color(0xFF155DFC),
                                  value: '${data.weeklyLessons}',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  borderColor: const Color(0xFFDCFCE7),
                                  gradientStart: const Color(0xFFF0FDF4),
                                  gradientEnd: const Color(0xFFFFFFFF),
                                  icon: Icons.schedule,
                                  iconColor: const Color(0xFF00A63E),
                                  title: 'PRÓXIMA AULA',
                                  titleColor: const Color(0xFF00A63E),
                                  value: data.nextLessonText,
                                  valueIsSmall: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Seus Explicadores',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101828),
                              height: 28 / 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (!hasHistory)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF3F4F6)),
                              ),
                              child: const Text(
                                'Ainda nunca teve uma aula nesta área.',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF4A5565),
                                  height: 20 / 14,
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                for (var i = 0; i < tutors.length; i++) ...[
                                  _TutorCard(
                                    initials: _initialsFor(tutors[i].tutorName),
                                    name: tutors[i].tutorName,
                                    rating: tutors[i].rating?.toStringAsFixed(1) ?? '—',
                                    lessonsText: tutors[i].lastLessonSubject == null || tutors[i].lastLessonSubject!.trim().isEmpty
                                        ? 'Sem disciplina registada'
                                        : 'Última aula: ${tutors[i].lastLessonSubject}',
                                    nextLessonPillText: _formatLessonMoment(tutors[i].lastLessonStart),
                                    disciplines: widget.area.selectedDisciplinaNames,
                                    onOpenProfile: () => _openTutorProfile(tutors[i]),
                                    onScheduleLesson: () => _openScheduleLesson(tutors[i]),
                                  ),
                                  if (i < tutors.length - 1) const SizedBox(height: 16),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 97,
                  decoration: const BoxDecoration(
                    color: _mutedSurface,
                    border: Border(top: BorderSide(color: _divider)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF364153),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 24 / 16,
                          ),
                        ),
                        child: const Text('Fechar'),
                      ),
                      SizedBox(
                        height: 48,
                        width: 194.117,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AreasAlunoConstants.orangeGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(Routes.explicadores);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Adicionar Explicador',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 24 / 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.area,
    required this.tutorCount,
    required this.onClose,
  });

  final AreaOverview area;
  final int tutorCount;
  final VoidCallback onClose;

  static const _headerColor = Color.fromRGBO(43, 127, 255, 0.69);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      color: _headerColor,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22.128),
            child: SizedBox(
              width: 88.511,
              height: 88.511,
              child: Center(
                child: Image.asset(
                  area.imageAsset,
                  width: 81.702,
                  height: 81.702,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 32 / 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tutorCount == 0
                      ? 'Ainda sem explicadores nesta área'
                      : '$tutorCount explicador${tutorCount == 1 ? '' : 'es'} nesta área',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onClose,
                child: const Center(
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _initialsFor(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '??';
  if (parts.length == 1) {
    final text = parts.first;
    return text.length >= 2 ? text.substring(0, 2).toUpperCase() : text.substring(0, 1).toUpperCase();
  }
  final first = parts.first;
  final last = parts.last;
  final firstInitial = first.isNotEmpty ? first.substring(0, 1) : '?';
  final lastInitial = last.isNotEmpty ? last.substring(0, 1) : '?';
  return '$firstInitial$lastInitial'.toUpperCase();
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.borderColor,
    required this.gradientStart,
    required this.gradientEnd,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.titleColor,
    required this.value,
    this.valueIsSmall = false,
  });

  final Color borderColor;
  final Color gradientStart;
  final Color gradientEnd;
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color titleColor;
  final String value;
  final bool valueIsSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                  height: 16 / 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: valueIsSmall ? 14 : 24,
              fontWeight: valueIsSmall ? FontWeight.w600 : FontWeight.bold,
              color: const Color(0xFF101828),
              height: (valueIsSmall ? 20 : 32) / (valueIsSmall ? 14 : 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorCard extends StatelessWidget {
  const _TutorCard({
    required this.initials,
    required this.name,
    required this.rating,
    required this.lessonsText,
    required this.nextLessonPillText,
    required this.disciplines,
    required this.onOpenProfile,
    required this.onScheduleLesson,
  });

  final String initials;
  final String name;
  final String rating;
  final String lessonsText;
  final String? nextLessonPillText;
  final List<String> disciplines;
  final VoidCallback onOpenProfile;
  final VoidCallback onScheduleLesson;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(21, 21, 21, 1),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.10),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.10),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE5E7EB),
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF364153),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101828),
                              height: 28 / 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 16, color: Color(0xFFFACC15)),
                              const SizedBox(width: 8),
                              Text(
                                rating,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF4A5565),
                                  height: 20 / 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF99A1AF),
                                  height: 20 / 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  lessonsText,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF4A5565),
                                    height: 20 / 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (nextLessonPillText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          nextLessonPillText!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF008236),
                            height: 16 / 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final d in disciplines)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF364153),
                            height: 16 / 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AreasAlunoConstants.orangeGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextButton(
                            onPressed: onScheduleLesson,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Marcar Aula',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                height: 20 / 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                      height: 42,
                      child: OutlinedButton(
                          onPressed: onOpenProfile,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Ver Perfil',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF364153),
                              height: 24 / 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaMarkLessonData {
  const _AreaMarkLessonData({
    this.tutors = const <MyTutorDto>[],
    this.weeklyLessons = 0,
    this.nextLessonText = 'nenhuma',
  });

  final List<MyTutorDto> tutors;
  final int weeklyLessons;
  final String nextLessonText;
}
