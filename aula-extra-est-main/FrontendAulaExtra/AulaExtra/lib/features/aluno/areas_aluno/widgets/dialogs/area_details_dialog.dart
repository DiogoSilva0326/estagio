import 'package:aula_extra/core/data/notifications/dtos/user_notification_dto.dart';
import 'package:aula_extra/core/data/notifications/notifications_service.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/student_area_summary_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/core/data/tutors/dtos/tutor_browse_item_dto.dart';
import 'package:aula_extra/core/data/tutors/tutors_browse_service.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:aula_extra/features/aluno/areas_aluno/models/area_overview.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

Future<void> showAreaDetailsDialog(
  BuildContext context, {
  required AreaOverview area,
}) {
  final isMobile =
      MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;
  if (isMobile) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Detalhes da área',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => AreaDetailsDialog(area: area),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AreaDetailsDialog(area: area),
  );
}

class AreaDetailsDialog extends StatefulWidget {
  const AreaDetailsDialog({super.key, required this.area});

  final AreaOverview area;

  @override
  State<AreaDetailsDialog> createState() => _AreaDetailsDialogState();
}

class _AreaDetailsDialogState extends State<AreaDetailsDialog> {
  final _calendarService = ReservationsCalendarService();
  final _notificationsService = NotificationsService();
  final _tutorsBrowseService = TutorsBrowseService();

  late final Future<_AreaDetailsData> _detailsFuture;

  static const _dialogRadius = 16.0;
  static const _surface = Color(0xFFFFFFFF);
  static const _mutedSurface = Color(0xFFF9FAFB);
  static const _divider = Color(0xFFE5E7EB);

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<_AreaDetailsData> _loadDetails() async {
    StudentAreaSummaryDto? summary;
    List<TutorBrowseItemDto> tutors = const [];
    List<UserNotificationDto> notifications = const [];

    if (widget.area.idArea.trim().isNotEmpty) {
      try {
        summary = await _calendarService.getMyAreaSummary(
          areaId: widget.area.idArea.trim(),
        );
      } catch (_) {}

      try {
        final response = await _tutorsBrowseService.browse(
          areaId: widget.area.idArea.trim(),
          page: 1,
          pageSize: 3,
        );
        tutors = response.items;
      } catch (_) {}
    }

    try {
      notifications = await _notificationsService.fetchMyNotifications();
    } catch (_) {}

    return _AreaDetailsData(
      completedLessons:
          summary?.completedLessons ?? widget.area.scheduledLessons,
      pendingTasks: _countRelatedPendingTasks(notifications),
      nextLessonText: _formatNextLesson(summary) ?? widget.area.nextLessonText,
      tutors: tutors,
      subtitle: tutors.isEmpty
          ? 'Ainda não tem um explicador nesta área'
          : '${tutors.length} explicador${tutors.length == 1 ? '' : 'es'} recomendado${tutors.length == 1 ? '' : 's'} nesta área',
    );
  }

  int _countRelatedPendingTasks(List<UserNotificationDto> notifications) {
    final tokens = <String>{
      widget.area.name.trim().toLowerCase(),
      ...widget.area.selectedDisciplinaNames
          .map((name) => name.trim().toLowerCase())
          .where((name) => name.isNotEmpty),
    }..removeWhere((token) => token.isEmpty);

    return notifications.where((notification) {
      if (notification.kind != UserNotificationKind.tarefa ||
          notification.isRead) {
        return false;
      }

      final text = '${notification.title} ${notification.message}'
          .toLowerCase();
      if (tokens.isEmpty) return true;
      return tokens.any(text.contains);
    }).length;
  }

  String? _formatNextLesson(StudentAreaSummaryDto? summary) {
    final start = summary?.nextLessonStart;
    if (start == null) return null;

    const weekdays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final weekday = weekdays[start.weekday - 1];
    final day = start.day.toString().padLeft(2, '0');
    final month = start.month.toString().padLeft(2, '0');
    final hour = start.hour.toString().padLeft(2, '0');
    final minute = start.minute.toString().padLeft(2, '0');
    return '$weekday, $day/$month • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    return FutureBuilder<_AreaDetailsData>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        final details =
            snapshot.data ??
            _AreaDetailsData(
              completedLessons: widget.area.scheduledLessons,
              pendingTasks: widget.area.pendingTasks,
              nextLessonText: widget.area.nextLessonText,
              tutors: const [],
              subtitle: 'Ainda não tem um explicador nesta área',
            );

        if (isMobile) {
          return _AreaDetailsMobileSheet(
            area: widget.area,
            details: details,
            loading: snapshot.connectionState == ConnectionState.waiting,
          );
        }

        return Dialog(
          backgroundColor: _surface,
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
                  subtitle: details.subtitle,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 39, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
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
                                  title: 'AULAS JÁ TIDAS',
                                  titleColor: const Color(0xFF155DFC),
                                  value: '${details.completedLessons}',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _StatCard(
                                  borderColor: const Color(0xFFFFEDD4),
                                  gradientStart: const Color(0xFFFFF7ED),
                                  gradientEnd: const Color(0xFFFFFFFF),
                                  icon: Icons.assignment_outlined,
                                  iconColor: const Color(0xFFF54900),
                                  title: 'TAREFAS',
                                  titleColor: const Color(0xFFF54900),
                                  value: '${details.pendingTasks}',
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
                                  value: details.nextLessonText,
                                  valueIsSmall: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(21, 18, 21, 18),
                            decoration: BoxDecoration(
                              color: _mutedSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Disciplinas selecionadas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF101828),
                                    height: 24 / 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (widget.area.selectedDisciplinaNames.isEmpty)
                                  const Text(
                                    'Nenhuma disciplina selecionada nesta área.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF4A5565),
                                      height: 20 / 14,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final name
                                          in widget
                                              .area
                                              .selectedDisciplinaNames)
                                        Chip(
                                          label: Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF4A5565),
                                            ),
                                          ),
                                          backgroundColor: const Color(
                                            0xFFF3F4F6,
                                          ),
                                          side: BorderSide.none,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(21),
                            decoration: BoxDecoration(
                              color: _mutedSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Explicadores desta área',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF101828),
                                    height: 28 / 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  details.tutors.isEmpty
                                      ? 'Ainda não encontrámos explicadores sugeridos para esta área.'
                                      : 'Veja alguns explicadores que lecionam esta área e explore mais opções.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF4A5565),
                                    height: 20 / 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (details.tutors.isEmpty)
                                  const _EmptyTutorsState()
                                else
                                  Column(
                                    children: [
                                      for (
                                        var index = 0;
                                        index < details.tutors.length;
                                        index++
                                      ) ...[
                                        _TutorSuggestionCard(
                                          tutor: details.tutors[index],
                                          onTap: () {
                                            final tutor = details.tutors[index];
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pushNamed(
                                              Routes.tutorProfile,
                                              arguments: TutorProfileArgs(
                                                professorId: tutor.idProfessor,
                                                name: tutor.name,
                                                country:
                                                    tutor.subtitle.isNotEmpty
                                                    ? tutor.subtitle
                                                    : 'Online',
                                                rating: tutor.rating,
                                                reviewCount: tutor.reviewCount,
                                                description: tutor.description,
                                                lessonsText:
                                                    '${tutor.lessonsCount} aulas',
                                                pricePerHour: tutor.minPrice
                                                    .round(),
                                                tags: tutor.tags,
                                              ),
                                            );
                                          },
                                        ),
                                        if (index < details.tutors.length - 1)
                                          const SizedBox(height: 12),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(21),
                            decoration: BoxDecoration(
                              color: _mutedSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  details.tutors.isEmpty
                                      ? 'Ainda não tem um explicador nesta área. Vamos encontrar um?'
                                      : 'Quer ver mais opções de explicadores para esta área?',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF101828),
                                    height: 28 / 18,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  height: 48,
                                  width: 194.117,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient:
                                          AreasAlunoConstants.orangeGradient,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        Navigator.of(
                                          context,
                                        ).pushNamed(Routes.explicadores);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Encontrar explicadores',
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

class _AreaDetailsMobileSheet extends StatelessWidget {
  const _AreaDetailsMobileSheet({
    required this.area,
    required this.details,
    required this.loading,
  });

  final AreaOverview area;
  final _AreaDetailsData details;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2B7FFF), Color(0xFF6AA7FF)],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Center(
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: SizedBox(
                      width: 84,
                      height: 84,
                      child: Center(
                        child: Image.asset(
                          area.imageAsset,
                          width: 76,
                          height: 76,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    area.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(255, 255, 255, 0.92),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (loading)
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
                          child: _MobileStatCard(
                            title: 'Aulas',
                            value: '${details.completedLessons}',
                            accent: const Color(0xFF155DFC),
                            bg: const Color(0xFFEFF6FF),
                            icon: Icons.menu_book_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MobileStatCard(
                            title: 'Tarefas',
                            value: '${details.pendingTasks}',
                            accent: const Color(0xFFF54900),
                            bg: const Color(0xFFFFF7ED),
                            icon: Icons.assignment_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MobileStatCard(
                            title: 'Próxima',
                            value: details.nextLessonText,
                            accent: const Color(0xFF00A63E),
                            bg: const Color(0xFFF0FDF4),
                            icon: Icons.schedule,
                            smallValue: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Disciplinas selecionadas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101828),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (area.selectedDisciplinaNames.isEmpty)
                            const Text(
                              'Nenhuma disciplina selecionada nesta área.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF4A5565),
                                height: 1.45,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final name in area.selectedDisciplinaNames)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4A5565),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Explicadores desta área',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF101828),
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            details.tutors.isEmpty
                                ? 'Ainda não encontrámos explicadores sugeridos para esta área.'
                                : 'Veja alguns explicadores que lecionam esta área e explore mais opções.',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4A5565),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (details.tutors.isEmpty)
                            const _EmptyTutorsState()
                          else
                            Column(
                              children: [
                                for (
                                  var index = 0;
                                  index < details.tutors.length;
                                  index++
                                ) ...[
                                  _MobileTutorSuggestionCard(
                                    tutor: details.tutors[index],
                                  ),
                                  if (index < details.tutors.length - 1)
                                    const SizedBox(height: 12),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AreasAlunoConstants.orangeGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(
                              context,
                            ).pushNamed(Routes.explicadores);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Encontrar explicadores',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileStatCard extends StatelessWidget {
  const _MobileStatCard({
    required this.title,
    required this.value,
    required this.accent,
    required this.bg,
    required this.icon,
    this.smallValue = false,
  });

  final String title;
  final String value;
  final Color accent;
  final Color bg;
  final IconData icon;
  final bool smallValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: accent),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: smallValue ? 13 : 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF101828),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileTutorSuggestionCard extends StatelessWidget {
  const _MobileTutorSuggestionCard({required this.tutor});

  final TutorBrowseItemDto tutor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFFFEDD5),
                child: Text(
                  tutor.name.isNotEmpty
                      ? tutor.name.characters.first.toUpperCase()
                      : 'E',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF54900),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF101828),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tutor.subtitle.isNotEmpty ? tutor.subtitle : 'Online',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A5565),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${tutor.minPrice.round()}€/h',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF54900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 16,
                color: Color(0xFFFC9039),
              ),
              const SizedBox(width: 4),
              Text(
                '${tutor.rating.toStringAsFixed(1)} (${tutor.reviewCount})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF364153),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.menu_book_outlined,
                size: 16,
                color: Color(0xFF6A7282),
              ),
              const SizedBox(width: 4),
              Text(
                '${tutor.lessonsCount} aulas',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF364153),
                ),
              ),
            ],
          ),
          if (tutor.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in tutor.tags.take(3))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A5565),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  Routes.tutorProfile,
                  arguments: TutorProfileArgs(
                    professorId: tutor.idProfessor,
                    name: tutor.name,
                    country: tutor.subtitle.isNotEmpty
                        ? tutor.subtitle
                        : 'Online',
                    rating: tutor.rating,
                    reviewCount: tutor.reviewCount,
                    description: tutor.description,
                    lessonsText: '${tutor.lessonsCount} aulas',
                    pricePerHour: tutor.minPrice.round(),
                    tags: tutor.tags,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                foregroundColor: const Color(0xFFF54900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ver perfil',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.area,
    required this.subtitle,
    required this.onClose,
  });

  final AreaOverview area;
  final String subtitle;
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
                  subtitle,
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

class _AreaDetailsData {
  const _AreaDetailsData({
    required this.completedLessons,
    required this.pendingTasks,
    required this.nextLessonText,
    required this.tutors,
    required this.subtitle,
  });

  final int completedLessons;
  final int pendingTasks;
  final String nextLessonText;
  final List<TutorBrowseItemDto> tutors;
  final String subtitle;
}

class _EmptyTutorsState extends StatelessWidget {
  const _EmptyTutorsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'Sem sugestões neste momento. Pode usar o botão abaixo para explorar a página completa de explicadores.',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF4A5565),
          height: 20 / 14,
        ),
      ),
    );
  }
}

class _TutorSuggestionCard extends StatelessWidget {
  const _TutorSuggestionCard({required this.tutor, required this.onTap});

  final TutorBrowseItemDto tutor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFFEDD5),
            child: Text(
              tutor.name.isNotEmpty
                  ? tutor.name.characters.first.toUpperCase()
                  : 'E',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF54900),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tutor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                          height: 24 / 16,
                        ),
                      ),
                    ),
                    Text(
                      '${tutor.minPrice.round()}€/h',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF54900),
                        height: 24 / 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tutor.subtitle.isNotEmpty ? tutor.subtitle : 'Online',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4A5565),
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFC9039),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tutor.rating.toStringAsFixed(1)} (${tutor.reviewCount})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF364153),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.menu_book_outlined,
                      size: 16,
                      color: Color(0xFF6A7282),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${tutor.lessonsCount} aulas',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF364153),
                      ),
                    ),
                  ],
                ),
                if (tutor.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in tutor.tags.take(3))
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4A5565),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFF54900),
            ),
            child: const Text('Ver perfil'),
          ),
        ],
      ),
    );
  }
}
