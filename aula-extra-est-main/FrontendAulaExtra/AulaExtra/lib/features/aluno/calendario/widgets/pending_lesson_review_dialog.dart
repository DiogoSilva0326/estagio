import 'package:aula_extra/core/data/reservations_calendar/calendar_status.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/features/aluno/calendario/state/student_calendar_refresh_bus.dart';
import 'package:flutter/material.dart';

class PendingLessonReviewData {
  const PendingLessonReviewData({
    required this.idReservation,
    required this.subject,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  final String idReservation;
  final String subject;
  final String teacherName;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
}

Future<bool?> showPendingLessonReviewDialog(
  BuildContext context, {
  required PendingLessonReviewData lesson,
  required ReservationsCalendarService calendarService,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PendingLessonReviewDialog(
      lesson: lesson,
      calendarService: calendarService,
    ),
  );
}

class _PendingLessonReviewDialog extends StatefulWidget {
  const _PendingLessonReviewDialog({
    required this.lesson,
    required this.calendarService,
  });

  final PendingLessonReviewData lesson;
  final ReservationsCalendarService calendarService;

  @override
  State<_PendingLessonReviewDialog> createState() =>
      _PendingLessonReviewDialogState();
}

class _PendingLessonReviewDialogState
    extends State<_PendingLessonReviewDialog> {
  bool _isSubmitting = false;

  static const _weekdays = [
    'segunda-feira',
    'terça-feira',
    'quarta-feira',
    'quinta-feira',
    'sexta-feira',
    'sábado',
    'domingo',
  ];

  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  String get _initials {
    final parts = widget.lesson.teacherName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'PR';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _accept() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.calendarService.acceptReservation(
        reservationId: widget.lesson.idReservation,
      );
      StudentCalendarRefreshBus.notifyChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Explicação aceite com sucesso.'),
          backgroundColor: Color(0xFF12B76A),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: const Color(0xFFFB2C36),
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _isSubmitting = true);
    try {
      await widget.calendarService.rejectReservation(
        reservationId: widget.lesson.idReservation,
      );
      StudentCalendarRefreshBus.notifyChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Explicação recusada com sucesso.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      Navigator.of(context).pop(false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: const Color(0xFFFB2C36),
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  String _formatLongDate(DateTime value) {
    final weekday = _weekdays[value.weekday - 1];
    final month = _months[value.month - 1];
    return '$weekday, ${value.day} de $month';
  }

  String _formatHour(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final palette = calendarStatusPalette(widget.lesson.status);
    final dateLabel = _formatLongDate(widget.lesson.startTime);
    final timeLabel =
        '${_formatHour(widget.lesson.startTime)} - ${_formatHour(widget.lesson.endTime)}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 42),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFF6B00), Color(0xFFFF9A62)],
                  ),
                ),
                child: const Text(
                  'Revisão da marcação',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(16, 24, 40, 0.08),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: const Color(0xFFFFEEE3),
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF6B00),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.lesson.teacherName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: palette.background,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: palette.border),
                        ),
                        child: Text(
                          widget.lesson.subject,
                          style: TextStyle(
                            color: palette.text,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _InfoRow(
                        icon: Icons.event_outlined,
                        label:
                            dateLabel[0].toUpperCase() + dateLabel.substring(1),
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(icon: Icons.schedule_rounded, label: timeLabel),
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.hourglass_top_rounded,
                        label: calendarStatusLabel(widget.lesson.status),
                        labelColor: palette.text,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _reject,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          side: const BorderSide(color: Color(0xFFFB2C36)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Recusar',
                          style: TextStyle(
                            color: Color(0xFFFB2C36),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _accept,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(56),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Aceitar marcação',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, this.labelColor});

  final IconData icon;
  final String label;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF667085)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: labelColor ?? const Color(0xFF344054),
            ),
          ),
        ),
      ],
    );
  }
}
