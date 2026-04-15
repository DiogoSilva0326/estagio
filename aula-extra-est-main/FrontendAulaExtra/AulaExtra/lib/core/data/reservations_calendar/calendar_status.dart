import 'package:flutter/material.dart';

class CalendarStatusPalette {
  const CalendarStatusPalette({
    required this.background,
    required this.border,
    required this.accent,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color accent;
  final Color text;
}

String normalizeCalendarStatus(String? status) {
  final value = status?.trim().toLowerCase() ?? '';
  if (value.isEmpty) return 'accepted';
  if (value == 'pending' ||
      value == 'waiting' ||
      value == 'requested' ||
      value == 'pendingpayment' ||
      value == 'pending_payment' ||
      value == 'awaiting_payment') {
    return 'pending';
  }
  if (value == 'accepted' ||
      value == 'active' ||
      value == 'scheduled' ||
      value == 'confirmed') {
    return 'accepted';
  }
  if (value == 'cancelled' ||
      value == 'canceled' ||
      value == 'cancelada' ||
      value == 'cancelado') {
    return 'cancelled';
  }
  return value;
}

bool isPendingCalendarStatus(String? status) =>
    normalizeCalendarStatus(status) == 'pending';

bool isAcceptedCalendarStatus(String? status) =>
    normalizeCalendarStatus(status) == 'accepted';

String calendarStatusLabel(String? status) {
  final normalized = status?.trim().toLowerCase() ?? '';
  if (normalized == 'pendingpayment' ||
      normalized == 'pending_payment' ||
      normalized == 'awaiting_payment') {
    return 'A aguardar pagamento';
  }

  switch (normalizeCalendarStatus(status)) {
    case 'pending':
      return 'A aguardar aceitação';
    case 'cancelled':
      return 'Cancelada';
    case 'accepted':
      return 'Confirmada';
    default:
      return 'Agendada';
  }
}

CalendarStatusPalette calendarStatusPalette(String? status) {
  switch (normalizeCalendarStatus(status)) {
    case 'pending':
      return const CalendarStatusPalette(
        background: Color(0xFFFFF7E8),
        border: Color(0xFFF59E0B),
        accent: Color(0xFFF59E0B),
        text: Color(0xFFB45309),
      );
    case 'cancelled':
      return const CalendarStatusPalette(
        background: Color(0xFFFEF3F2),
        border: Color(0xFFF04438),
        accent: Color(0xFFF04438),
        text: Color(0xFFB42318),
      );
    case 'accepted':
    default:
      return const CalendarStatusPalette(
        background: Color(0xFFECFDF3),
        border: Color(0xFF12B76A),
        accent: Color(0xFF12B76A),
        text: Color(0xFF027A48),
      );
  }
}
