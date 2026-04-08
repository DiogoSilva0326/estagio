import 'package:flutter/material.dart';

enum UserNotificationKind { aula, tarefa, mensagem, avaliacao, pagamento }

class UserNotificationDto {
  const UserNotificationDto({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.metadata,
    this.reservationId,
    this.teacherName,
    this.subject,
    this.startTime,
    this.endTime,
    this.creationDate,
    this.lastUpdate,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final Map<String, String> metadata;
  final String? reservationId;
  final String? teacherName;
  final String? subject;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? creationDate;
  final DateTime? lastUpdate;

  DateTime? get effectiveDate => lastUpdate ?? creationDate;
  bool get unread => !isRead;
  String? get studentUserId => metadata['studentUserId'];
  String? get studentName => metadata['studentName'];
  String? get justification => metadata['justification'];
  bool get decisionMade => metadata['decisionMade']?.toLowerCase() == 'true';
  String? get decision => metadata['decision'];
  bool get isLessonReviewRequest =>
      type.trim().toLowerCase() == 'marcar_aula' &&
      (reservationId?.trim().isNotEmpty ?? false);
  bool get isJustifiedCancellationRequest {
    final normalizedType = type.trim().toLowerCase();
    final normalizedTitle = title.trim().toLowerCase();
    return normalizedType == 'cancelamento justificado' ||
        normalizedTitle == 'cancelamento justificado';
  }

  String get displayMessage => _stripMetadata(message);

  UserNotificationKind get kind {
    if (type.trim().toLowerCase() == 'marcar_aula') {
      return UserNotificationKind.aula;
    }

    final text = '${title.toLowerCase()} ${message.toLowerCase()}';
    if (text.contains('tarefa') ||
        text.contains('exerc') ||
        text.contains('trabalho')) {
      return UserNotificationKind.tarefa;
    }
    if (text.contains('mensag') || text.contains('chat')) {
      return UserNotificationKind.mensagem;
    }
    if (text.contains('avali') || text.contains('feedback')) {
      return UserNotificationKind.avaliacao;
    }
    if (text.contains('pagamento') ||
        text.contains('recibo') ||
        text.contains('crédito') ||
        text.contains('credito')) {
      return UserNotificationKind.pagamento;
    }
    return UserNotificationKind.aula;
  }

  IconData get icon {
    switch (kind) {
      case UserNotificationKind.aula:
        return Icons.access_time_rounded;
      case UserNotificationKind.tarefa:
        return Icons.assignment_rounded;
      case UserNotificationKind.mensagem:
        return Icons.chat_bubble_rounded;
      case UserNotificationKind.avaliacao:
        return Icons.star_rounded;
      case UserNotificationKind.pagamento:
        return Icons.payments_rounded;
    }
  }

  Color get iconBackground {
    switch (kind) {
      case UserNotificationKind.aula:
        return const Color(0xFF00C950);
      case UserNotificationKind.tarefa:
        return const Color(0xFF2B7FFF);
      case UserNotificationKind.mensagem:
        return const Color(0xFFAD46FF);
      case UserNotificationKind.avaliacao:
        return const Color(0xFFF0B100);
      case UserNotificationKind.pagamento:
        return const Color(0xFFFF6900);
    }
  }

  UserNotificationDto copyWith({
    bool? isRead,
    String? message,
    DateTime? lastUpdate,
    Map<String, String>? metadata,
  }) {
    return UserNotificationDto(
      id: id,
      type: type,
      title: title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
      reservationId: reservationId,
      teacherName: teacherName,
      subject: subject,
      startTime: startTime,
      endTime: endTime,
      creationDate: creationDate,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  factory UserNotificationDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is! String || value.trim().isEmpty) return null;
      return DateTime.tryParse(value);
    }

    final rawMessage = json['message']?.toString().trim() ?? '';
    final metadata = _extractMetadata(rawMessage);

    return UserNotificationDto(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? '',
      message: rawMessage,
      isRead: json['isRead'] == true,
      metadata: metadata,
      reservationId: metadata['reservationId'],
      teacherName: metadata['teacherName'],
      subject: metadata['subject'],
      startTime: parseDate(metadata['start'])?.toLocal(),
      endTime: parseDate(metadata['end'])?.toLocal(),
      creationDate: parseDate(json['creationDate']),
      lastUpdate: parseDate(json['lastUpdate']),
    );
  }

  static Map<String, String> _extractMetadata(String rawMessage) {
    final match = RegExp(r'\[\[(.*?)\]\]\s*$').firstMatch(rawMessage);
    if (match == null) return const {};

    final payload = match.group(1)?.trim();
    if (payload == null || payload.isEmpty) return const {};

    try {
      return Uri.splitQueryString(payload);
    } catch (_) {
      return const {};
    }
  }

  static String _stripMetadata(String rawMessage) {
    return rawMessage.replaceFirst(RegExp(r'\s*\[\[(.*?)\]\]\s*$'), '').trim();
  }
}
