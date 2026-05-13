import 'package:flutter/material.dart';

import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../../../design/theme/app_colors.dart';
import '../constants/dashboard_mock_data.dart';
import '../models/dashboard_kpi_item.dart';
import '../models/dashboard_popular_subject_item.dart';
import '../models/dashboard_service_status_item.dart';
import '../models/dashboard_session_item.dart';

class DashboardViewData {
  const DashboardViewData({
    required this.kpis,
    required this.recentSessions,
    required this.serviceStatuses,
    required this.popularSubjects,
    this.warningMessage,
  });

  final List<DashboardKpiItem> kpis;
  final List<DashboardSessionItem> recentSessions;
  final List<DashboardServiceStatusItem> serviceStatuses;
  final List<DashboardPopularSubjectItem> popularSubjects;
  final String? warningMessage;

  bool get isFallback => warningMessage != null;

  factory DashboardViewData.fallback({String? warningMessage}) {
    return DashboardViewData(
      kpis: DashboardMockData.kpis,
      recentSessions: DashboardMockData.recentSessions,
      serviceStatuses: DashboardMockData.serviceStatuses,
      popularSubjects: DashboardMockData.popularSubjects,
      warningMessage: warningMessage,
    );
  }
}

class DashboardService {
  final BackofficeApiClient _client = BackofficeApiClient();

  Future<DashboardViewData> fetch() async {
    final token = BackofficeSessionController.instance.token;
    if (token == null || token.isEmpty) {
      return DashboardViewData.fallback(
        warningMessage: 'Sem sessão ativa. A mostrar dados de demonstração.',
      );
    }

    try {
      final payload = await _client.getJson(
        ApiConfig.uri('/api/admin/dashboard'),
        token: token,
      );

      final kpis = _mapKpis((payload['kpis'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{});
      final recentSessions = ((payload['recentSessions'] as List?) ?? const <dynamic>[])
          .map((item) => _mapSession((item as Map).cast<String, dynamic>()))
          .toList();
      final serviceStatuses = ((payload['services'] as List?) ?? const <dynamic>[])
          .map((item) => _mapService((item as Map).cast<String, dynamic>()))
          .toList();
      final popularSubjects = ((payload['popularSubjects'] as List?) ?? const <dynamic>[])
          .map((item) => _mapSubject((item as Map).cast<String, dynamic>()))
          .toList();

      return DashboardViewData(
        kpis: kpis,
        recentSessions: recentSessions.isEmpty ? DashboardMockData.recentSessions : recentSessions,
        serviceStatuses: serviceStatuses.isEmpty ? DashboardMockData.serviceStatuses : serviceStatuses,
        popularSubjects: popularSubjects.isEmpty ? DashboardMockData.popularSubjects : popularSubjects,
      );
    } catch (_) {
      return DashboardViewData.fallback(
        warningMessage: 'Não foi possível sincronizar o dashboard com a API. A mostrar dados de demonstração.',
      );
    }
  }

  List<DashboardKpiItem> _mapKpis(Map<String, dynamic> data) {
    final activeProfessionals = _asInt(data['activeProfessionals']);
    final totalStudents = _asInt(data['totalStudents']);
    final monthlySessions = _asInt(data['monthlySessions']);
    final monthlyRevenue = _asDouble(data['monthlyRevenue']);
    final pendingApplications = _asInt(data['pendingApplications']);

    return [
      DashboardKpiItem(
        title: 'Profissionais Ativos',
        value: '$activeProfessionals',
        subtitle: '$pendingApplications candidaturas por rever',
        icon: Icons.groups_2_outlined,
        iconColor: const Color(0xFFFB7B02),
        iconBackgroundColor: const Color(0x1FFB7B02),
      ),
      DashboardKpiItem(
        title: 'Total de Alunos',
        value: '$totalStudents',
        subtitle: 'Utilizadores com role aluno',
        icon: Icons.school_outlined,
        iconColor: const Color(0xFF41A7D7),
        iconBackgroundColor: const Color(0x1F41A7D7),
      ),
      DashboardKpiItem(
        title: 'Sessões do Mês',
        value: '$monthlySessions',
        subtitle: 'Reservas registadas este mês',
        icon: Icons.videocam_outlined,
        iconColor: const Color(0xFFFF5A5F),
        iconBackgroundColor: const Color(0x26FFBDC0),
      ),
      DashboardKpiItem(
        title: 'Receita Gerada',
        value: '€ ${monthlyRevenue.toStringAsFixed(2)}',
        subtitle: 'Pagamentos pagos este mês',
        icon: Icons.monetization_on_outlined,
        iconColor: const Color(0xFF4CAF50),
        iconBackgroundColor: const Color(0x1A4CAF50),
      ),
    ];
  }

  DashboardSessionItem _mapSession(Map<String, dynamic> data) {
    final startsAt = DateTime.tryParse(data['startsAt']?.toString() ?? '');
    final endsAt = DateTime.tryParse(data['endsAt']?.toString() ?? '');
    final now = DateTime.now();
    final rawStatus = (data['status']?.toString() ?? '').toLowerCase();

    String label;
    Color color;
    Color backgroundColor;
    bool showDot = false;

    if (startsAt != null && endsAt != null && now.isAfter(startsAt) && now.isBefore(endsAt)) {
      label = 'Em curso';
      color = const Color(0xFFFC9039);
      backgroundColor = const Color(0x1FFB7B02);
      showDot = true;
    } else if (rawStatus == 'paid' && endsAt != null && now.isAfter(endsAt)) {
      label = 'Concluída';
      color = const Color(0xFF4CAF50);
      backgroundColor = const Color(0x264CAF50);
    } else if (rawStatus == 'pending') {
      label = 'Pendente';
      color = const Color(0xFFED1C24);
      backgroundColor = const Color(0x26FFBDC0);
    } else {
      label = 'Agendada';
      color = const Color(0xFF41A7D7);
      backgroundColor = const Color(0x2641A7D7);
    }

    return DashboardSessionItem(
      student: data['studentName']?.toString() ?? '—',
      tutor: data['tutorName']?.toString() ?? '—',
      subject: data['subjectName']?.toString() ?? 'Sessão',
      subjectIcon: _iconForSubject(data['subjectName']?.toString() ?? ''),
      subjectColor: const Color(0xFF667085),
      subjectBackgroundColor: AppColors.surfaceMuted,
      dateLabel: startsAt == null ? '—' : _formatDate(startsAt),
      duration: '${_asInt(data['durationMinutes'])} min',
      statusLabel: label,
      statusColor: color,
      statusBackgroundColor: backgroundColor,
      showStatusDot: showDot,
    );
  }

  DashboardServiceStatusItem _mapService(Map<String, dynamic> data) {
    final label = data['label']?.toString() ?? 'Serviço';
    final online = data['online'] == true;
    final count = _asInt(data['count']);
    final isCount = (data['kind']?.toString() ?? '').toLowerCase() == 'count';

    if (isCount) {
      final isProblem = count > 0;
      return DashboardServiceStatusItem(
        label: label,
        badgeLabel: '$count',
        indicatorColor: isProblem ? const Color(0xFFFC9039) : const Color(0xFF4CAF50),
        badgeColor: isProblem ? const Color(0xFFFC9039) : const Color(0xFF4CAF50),
        badgeBackgroundColor: isProblem ? const Color(0x1FFB7B02) : const Color(0x1A4CAF50),
      );
    }

    return DashboardServiceStatusItem(
      label: label,
      badgeLabel: online ? 'ONLINE' : 'OFFLINE',
      indicatorColor: online ? const Color(0xFF4CAF50) : const Color(0xFFED1C24),
      badgeColor: online ? const Color(0xFF4CAF50) : const Color(0xFFED1C24),
      badgeBackgroundColor: online ? const Color(0x1A4CAF50) : const Color(0x26FFBDC0),
    );
  }

  DashboardPopularSubjectItem _mapSubject(Map<String, dynamic> data) {
    final label = data['label']?.toString() ?? 'Outro';
    return DashboardPopularSubjectItem(
      label: label,
      professorCountLabel: '${_asInt(data['professionalCount'])} Profs',
      icon: _iconForSubject(label),
      iconColor: const Color(0xFF41A7D7),
      iconBackgroundColor: const Color(0x2641A7D7),
    );
  }

  IconData _iconForSubject(String subject) {
    final normalized = subject.toLowerCase();
    if (normalized.contains('mat')) return Icons.calculate_outlined;
    if (normalized.contains('fís') || normalized.contains('fis') || normalized.contains('quím') || normalized.contains('quim')) return Icons.science_outlined;
    if (normalized.contains('ingl') || normalized.contains('portugu') || normalized.contains('língua') || normalized.contains('lingua')) return Icons.translate_outlined;
    if (normalized.contains('psico')) return Icons.psychology_outlined;
    if (normalized.contains('hist')) return Icons.account_balance_outlined;
    return Icons.auto_stories_outlined;
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month, $hour:$minute';
  }
}