import 'package:aula_extra/core/data/reservations_calendar/calendar_status.dart';
import 'package:aula_extra/core/data/reservations_calendar/dtos/reservation_payment_review_dto.dart';
import 'package:aula_extra/core/data/reservations_calendar/reservations_calendar_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/aluno/calendario/state/student_calendar_refresh_bus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  ReservationPaymentReviewDto? _paymentReview;
  bool _isLoadingReview = true;
  bool _isSubmitting = false;
  String? _loadingError;

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
    final teacherName = _paymentReview?.teacherName ?? widget.lesson.teacherName;
    final parts = teacherName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'PR';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _loadPaymentReview();
  }

  Future<void> _loadPaymentReview() async {
    setState(() {
      _isLoadingReview = true;
      _loadingError = null;
    });

    try {
      final review = await widget.calendarService.getReservationPaymentReview(
        reservationId: widget.lesson.idReservation,
      );
      if (!mounted) return;
      setState(() {
        _paymentReview = review;
        _isLoadingReview = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingError = error.toString();
        _isLoadingReview = false;
      });
    }
  }

  Future<void> _accept() async {
    setState(() => _isSubmitting = true);
    try {
      final review = _paymentReview;
      if (review == null) {
        throw Exception('Não foi possível validar o pagamento desta aula.');
      }

      if (review.amount > 0) {
        final result = await widget.calendarService.payAndAcceptReservation(
          reservationId: widget.lesson.idReservation,
        );
        if (!mounted) return;

        final provider = context.read<UserProvider>();
        provider.setAccount(
          (provider.account ?? const UserAccount()).copyWith(
            creditsBalance: result.studentBalanceAfter,
            creditsCurrency: result.currency,
          ),
        );
      } else {
        await widget.calendarService.acceptReservation(
          reservationId: widget.lesson.idReservation,
        );
      }

      StudentCalendarRefreshBus.notifyChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            review.amount > 0
                ? 'Pagamento confirmado e explicação aceite com sucesso.'
                : 'Explicação aceite com sucesso.',
          ),
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

  String _formatMoney(double amount, String currency) {
    final normalized = amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2);
    if (currency.toUpperCase() == 'EUR') {
      return '$normalized €';
    }

    return '$normalized $currency';
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final review = _paymentReview;
    final effectiveStatus = review?.reservationStatus ?? widget.lesson.status;
    final palette = calendarStatusPalette(effectiveStatus);
    final startTime = review?.startTime ?? widget.lesson.startTime;
    final endTime = review?.endTime ?? widget.lesson.endTime;
    final dateLabel = _formatLongDate(startTime);
    final timeLabel = '${_formatHour(startTime)} - ${_formatHour(endTime)}';
    final amount = review?.amount ?? 0;
    final availableCredits = review?.availableCredits ?? 0;
    final currency = review?.currency ?? 'EUR';
    final canAfford = review?.canAfford ?? true;
    final isPaymentRequired = amount > 0;
    final actionLabel = isPaymentRequired
        ? (review?.alreadyPaid == true ? 'Confirmar marcação' : 'Pagar e confirmar')
        : 'Aceitar marcação';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: viewportHeight - 48,
        ),
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
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                            review?.teacherName ?? widget.lesson.teacherName,
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
                              review?.subject ?? widget.lesson.subject,
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _InfoRow(
                            icon: Icons.event_outlined,
                            label: dateLabel[0].toUpperCase() + dateLabel.substring(1),
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(icon: Icons.schedule_rounded, label: timeLabel),
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.hourglass_top_rounded,
                            label: calendarStatusLabel(effectiveStatus),
                            labelColor: palette.text,
                          ),
                          if (review != null) ...[
                            const SizedBox(height: 10),
                            _InfoRow(
                              icon: Icons.video_camera_front_outlined,
                              label: review.tutoringTypeName.isEmpty
                                  ? 'Modalidade a confirmar'
                                  : review.tutoringTypeName,
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: _isLoadingReview
                                  ? const Center(child: CircularProgressIndicator())
                                  : _loadingError != null
                                  ? Text(
                                      _loadingError!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFFB42318),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        _PaymentRow(
                                          label: 'Preço da aula',
                                          value: _formatMoney(amount, currency),
                                          highlight: true,
                                        ),
                                        const SizedBox(height: 10),
                                        _PaymentRow(
                                          label: 'Saldo disponível',
                                          value: _formatMoney(availableCredits, currency),
                                        ),
                                        if (isPaymentRequired) ...[
                                          const SizedBox(height: 10),
                                          _PaymentRow(
                                            label: 'Saldo após pagamento',
                                            value: _formatMoney(
                                              availableCredits - amount,
                                              currency,
                                            ),
                                            valueColor: canAfford
                                                ? const Color(0xFF027A48)
                                                : const Color(0xFFB42318),
                                          ),
                                        ],
                                        const SizedBox(height: 14),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: canAfford
                                                ? const Color(0xFFECFDF3)
                                                : const Color(0xFFFEF3F2),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: canAfford
                                                  ? const Color(0xFF12B76A)
                                                  : const Color(0xFFF04438),
                                            ),
                                          ),
                                          child: Text(
                                            review.alreadyPaid
                                                ? 'O pagamento já foi registado. Só falta confirmar a marcação.'
                                                : isPaymentRequired
                                                ? canAfford
                                                    ? 'Ao confirmares, os créditos saem da tua carteira e a aula fica agendada.'
                                                    : 'Não tens créditos suficientes para pagar esta aula.'
                                                : 'Esta marcação não exige pagamento prévio.',
                                            style: TextStyle(
                                              color: canAfford
                                                  ? const Color(0xFF027A48)
                                                  : const Color(0xFFB42318),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ],
                      ),
                    ),
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
                          onPressed: _isSubmitting || _isLoadingReview || review == null || (!canAfford && isPaymentRequired)
                              ? null
                              : _accept,
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
                                : Text(
                                  actionLabel,
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

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool highlight;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: highlight ? const Color(0xFF101828) : const Color(0xFF667085),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF101828),
          ),
        ),
      ],
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
