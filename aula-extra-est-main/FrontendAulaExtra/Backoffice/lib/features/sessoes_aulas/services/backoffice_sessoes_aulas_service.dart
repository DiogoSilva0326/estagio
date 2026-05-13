import 'package:flutter/material.dart';

import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../models/sessao_aula_item.dart';

class BackofficeSessoesAulasViewData {
  const BackofficeSessoesAulasViewData({
    required this.items,
    this.warningMessage,
  });

  final List<SessaoAulaItem> items;
  final String? warningMessage;
}

class BackofficeSessoesAulasService {
  BackofficeSessoesAulasService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  })  : _apiClient = apiClient ?? BackofficeApiClient(),
        _sessionController =
            sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<BackofficeSessoesAulasViewData> fetch() async {
    await _sessionController.initialize();

    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      return const BackofficeSessoesAulasViewData(
        items: <SessaoAulaItem>[],
        warningMessage:
            'Sem sessão de administrador ativa. Inicie sessão para carregar as sessões.',
      );
    }

    try {
      final payload = await _apiClient.getJsonList(
        ApiConfig.uri('/api/admin/session-logs'),
        token: token,
      );

      return BackofficeSessoesAulasViewData(
        items: payload
            .whereType<Map>()
            .map((item) => _mapItem(item.cast<String, dynamic>()))
            .toList(growable: false),
      );
    } catch (_) {
      return const BackofficeSessoesAulasViewData(
        items: <SessaoAulaItem>[],
        warningMessage:
            'Não foi possível sincronizar as sessões e videochamadas com a API. Tente novamente.',
      );
    }
  }

  SessaoAulaItem _mapItem(Map<String, dynamic> json) {
    final reservationId = _stringValue(json['reservationId']);
    final videoCallId = _stringValue(json['videoCallId']);
    final startsAt = _parseDateTime(json['startsAt']);
    final endsAt = _parseDateTime(json['endsAt']);
    final callStartedAt = _parseDateTime(json['callStartedAt']);
    final callEndedAt = _parseDateTime(json['callEndedAt']);
    final now = DateTime.now();
    final reservationStatus = _stringValue(
      json['reservationStatus'],
      fallback: 'scheduled',
    ).toLowerCase();
    final videoCallStatus = _stringValue(json['videoCallStatus']).toLowerCase();
    final channelName = _nullableString(json['channelName']);
    final recordingUrl = _nullableString(json['recordingUrl']);
    final durationMinutes = _intValue(json['durationMinutes']);
    final callDurationSeconds = _intValue(json['callDurationSeconds']);

    final bool hasStartedCall =
      callStartedAt != null && !callStartedAt.toLocal().isAfter(now);
    final bool isLive = (<String>{'active', 'live', 'ongoing', 'in_progress'}
          .contains(videoCallStatus) ||
        hasStartedCall) &&
      (callEndedAt == null || callEndedAt.isAfter(now));
    final bool isConcluded = !isLive &&
        (recordingUrl != null ||
            <String>{'ended', 'finished', 'completed'}.contains(videoCallStatus) ||
            (endsAt != null && endsAt.isBefore(now) && reservationStatus != 'pending'));
    final bool isCancelled =
        <String>{'cancelled', 'canceled', 'rejected'}.contains(reservationStatus);
    final bool isPending = reservationStatus == 'pending';

    late final String statusLabel;
    late final Color statusColor;
    late final Color statusBackgroundColor;
    late final bool showStatusDot;

    if (isLive) {
      statusLabel = 'EM CURSO (LIVE)';
      statusColor = const Color(0xFFFC9039);
      statusBackgroundColor = const Color(0x1FFB7B02);
      showStatusDot = true;
    } else if (isCancelled) {
      statusLabel = 'CANCELADA';
      statusColor = const Color(0xFFED1C24);
      statusBackgroundColor = const Color(0x26FFBDC0);
      showStatusDot = false;
    } else if (isPending) {
      statusLabel = 'PENDENTE';
      statusColor = const Color(0xFFED1C24);
      statusBackgroundColor = const Color(0x26FFBDC0);
      showStatusDot = false;
    } else if (isConcluded) {
      statusLabel = 'CONCLUÍDA';
      statusColor = const Color(0xFF4CAF50);
      statusBackgroundColor = const Color(0x264CAF50);
      showStatusDot = false;
    } else {
      statusLabel = 'AGENDADA';
      statusColor = const Color(0xFF41A7D7);
      statusBackgroundColor = const Color(0x2641A7D7);
      showStatusDot = false;
    }

    final durationLabel = callDurationSeconds > 0
        ? _formatDurationFromSeconds(callDurationSeconds, isLive: isLive)
        : _formatDurationFromMinutes(durationMinutes, isLive: isLive);

    final linkLabel = recordingUrl != null
        ? 'Gravação'
        : (channelName != null && channelName.isNotEmpty ? 'Canal Agora' : '-');

    return SessaoAulaItem(
      id: reservationId,
      reservationId: reservationId,
      lessonId: _stringValue(json['lessonId']),
      videoCallId: videoCallId.isEmpty ? null : videoCallId,
      codigo: _buildCode(videoCallId: videoCallId, reservationId: reservationId),
      aluno: _stringValue(json['studentName'], fallback: 'Aluno'),
      explicador: _stringValue(json['tutorName'], fallback: 'Explicador'),
      disciplina: _stringValue(json['subjectName'], fallback: 'Sessão'),
      dataHora: _formatDateLabel(startsAt),
      duracao: durationLabel,
      linkSalaLabel: linkLabel,
      statusLabel: statusLabel,
      statusColor: statusColor,
      statusBackgroundColor: statusBackgroundColor,
      showStatusDot: showStatusDot,
      canEnterRoom: recordingUrl != null || (channelName != null && channelName.isNotEmpty),
      startsAt: startsAt,
      endsAt: endsAt,
      channelName: channelName,
      recordingUrl: recordingUrl,
      reservationStatus: reservationStatus,
      videoCallStatus: videoCallStatus,
    );
  }

  String _buildCode({
    required String videoCallId,
    required String reservationId,
  }) {
    String format(String prefix, String value) {
      final compact = value.replaceAll('-', '').toUpperCase();
      final suffix = compact.length <= 8 ? compact : compact.substring(0, 8);
      return '#$prefix-$suffix';
    }

    if (videoCallId.isNotEmpty) {
      return format('CALL', videoCallId);
    }

    return format('AUL', reservationId);
  }

  String _formatDateLabel(DateTime? value) {
    if (value == null) {
      return '—';
    }

    final local = value.toLocal();
    final now = DateTime.now();
    final isToday =
        now.year == local.year && now.month == local.month && now.day == local.day;

    final date = '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';

    return isToday ? 'Hoje, $time' : '$date, $time';
  }

  String _formatDurationFromMinutes(int value, {required bool isLive}) {
    final minutes = value <= 0 ? 0 : value;
    if (isLive) {
      return '$minutes min (decorrer)';
    }

    return '$minutes min';
  }

  String _formatDurationFromSeconds(int value, {required bool isLive}) {
    final minutes = (value / 60).round();
    return _formatDurationFromMinutes(minutes, isLive: isLive);
  }

  DateTime? _parseDateTime(Object? value) {
    final normalized = value?.toString().trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return DateTime.tryParse(normalized);
  }

  String? _nullableString(Object? value) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  String _stringValue(Object? value, {String fallback = ''}) {
    return _nullableString(value) ?? fallback;
  }

  int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}