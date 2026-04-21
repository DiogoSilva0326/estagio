import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/dashboard_kpi_item.dart';
import '../models/dashboard_popular_subject_item.dart';
import '../models/dashboard_service_status_item.dart';
import '../models/dashboard_session_item.dart';

class DashboardMockData {
  const DashboardMockData._();

  static const List<DashboardKpiItem> kpis = [
    DashboardKpiItem(
      title: 'Explicadores Ativos',
      value: '512',
      subtitle: '480 verificados, 32 pendentes',
      icon: Icons.groups_2_outlined,
      iconColor: Color(0xFFFB7B02),
      iconBackgroundColor: Color(0x1FFB7B02),
    ),
    DashboardKpiItem(
      title: 'Total de Alunos',
      value: '5.240',
      subtitle: '+120 esta semana',
      icon: Icons.school_outlined,
      iconColor: Color(0xFF41A7D7),
      iconBackgroundColor: Color(0x1F41A7D7),
    ),
    DashboardKpiItem(
      title: 'Sessões Mensais',
      value: '1.284',
      subtitle: 'Através de videochamada',
      icon: Icons.videocam_outlined,
      iconColor: Color(0xFFFF5A5F),
      iconBackgroundColor: Color(0x26FFBDC0),
    ),
    DashboardKpiItem(
      title: 'Receita Gerada',
      value: '€ 12.450',
      subtitle: 'Comissões faturadas este mês',
      icon: Icons.monetization_on_outlined,
      iconColor: Color(0xFF4CAF50),
      iconBackgroundColor: Color(0x1A4CAF50),
    ),
  ];

  static const List<DashboardSessionItem> recentSessions = [
    DashboardSessionItem(
      student: 'João Silva',
      tutor: 'Ana Rodrigues',
      subject: 'Matemática',
      subjectIcon: Icons.calculate_outlined,
      subjectColor: Color(0xFF667085),
      subjectBackgroundColor: AppColors.surfaceMuted,
      dateLabel: 'Hoje, 14:30',
      duration: '60 min',
      statusLabel: 'Concluída',
      statusColor: Color(0xFF4CAF50),
      statusBackgroundColor: Color(0x264CAF50),
    ),
    DashboardSessionItem(
      student: 'Maria Santos',
      tutor: 'Carlos Ferreira',
      subject: 'Física',
      subjectIcon: Icons.science_outlined,
      subjectColor: Color(0xFF667085),
      subjectBackgroundColor: AppColors.surfaceMuted,
      dateLabel: 'Hoje, 16:00',
      duration: '-',
      statusLabel: 'Em curso',
      statusColor: Color(0xFFFC9039),
      statusBackgroundColor: Color(0x1FFB7B02),
      showStatusDot: true,
    ),
    DashboardSessionItem(
      student: 'Pedro Costa',
      tutor: 'João Silva',
      subject: 'Inglês',
      subjectIcon: Icons.translate_outlined,
      subjectColor: Color(0xFF667085),
      subjectBackgroundColor: AppColors.surfaceMuted,
      dateLabel: 'Amanhã, 10:00',
      duration: '-',
      statusLabel: 'Agendada',
      statusColor: Color(0xFF41A7D7),
      statusBackgroundColor: Color(0x2641A7D7),
    ),
    DashboardSessionItem(
      student: 'Ana Rita',
      tutor: 'Maria Santos',
      subject: 'Química',
      subjectIcon: Icons.biotech_outlined,
      subjectColor: Color(0xFF667085),
      subjectBackgroundColor: AppColors.surfaceMuted,
      dateLabel: 'Ontem, 18:00',
      duration: '-',
      statusLabel: 'Cancelada',
      statusColor: Color(0xFFED1C24),
      statusBackgroundColor: Color(0x26FFBDC0),
    ),
  ];

  static const List<DashboardSessionItem> allSessions = [
    ...recentSessions,
    DashboardSessionItem(
      student: 'Ana Rita',
      tutor: 'Maria Santos',
      subject: 'Química',
      subjectIcon: Icons.biotech_outlined,
      subjectColor: Color(0xFF667085),
      subjectBackgroundColor: AppColors.surfaceMuted,
      dateLabel: 'Ontem, 18:00',
      duration: '-',
      statusLabel: 'Cancelada',
      statusColor: Color(0xFFED1C24),
      statusBackgroundColor: Color(0x26FFBDC0),
    ),
    DashboardSessionItem(
      student: 'Ana Rita',
      tutor: 'Maria Santos',
      subject: 'Química',
      subjectIcon: Icons.biotech_outlined,
      subjectColor: Color(0xFF667085),
      subjectBackgroundColor: AppColors.surfaceMuted,
      dateLabel: 'Ontem, 18:00',
      duration: '-',
      statusLabel: 'Cancelada',
      statusColor: Color(0xFFED1C24),
      statusBackgroundColor: Color(0x26FFBDC0),
    ),
    DashboardSessionItem(
      student: 'Ana Rita',
      tutor: 'Maria Santos',
      subject: 'Química',
      subjectIcon: Icons.biotech_outlined,
      subjectColor: Color(0xFF667085),
      subjectBackgroundColor: AppColors.surfaceMuted,
      dateLabel: 'Ontem, 18:00',
      duration: '-',
      statusLabel: 'Cancelada',
      statusColor: Color(0xFFED1C24),
      statusBackgroundColor: Color(0x26FFBDC0),
    ),
    DashboardSessionItem(
      student: 'Ana Rita',
      tutor: 'Maria Santos',
      subject: 'Química',
      subjectIcon: Icons.biotech_outlined,
      subjectColor: Color(0xFF667085),
      subjectBackgroundColor: AppColors.surfaceMuted,
      dateLabel: 'Ontem, 18:00',
      duration: '-',
      statusLabel: 'Cancelada',
      statusColor: Color(0xFFED1C24),
      statusBackgroundColor: Color(0x26FFBDC0),
    ),
  ];

  static const List<DashboardServiceStatusItem> serviceStatuses = [
    DashboardServiceStatusItem(
      label: 'API Backend',
      badgeLabel: 'ONLINE',
      indicatorColor: Color(0xFF4CAF50),
      badgeColor: Color(0xFF4CAF50),
      badgeBackgroundColor: Color(0x1A4CAF50),
    ),
    DashboardServiceStatusItem(
      label: 'Videochamadas',
      badgeLabel: 'ONLINE',
      indicatorColor: Color(0xFF4CAF50),
      badgeColor: Color(0xFF4CAF50),
      badgeBackgroundColor: Color(0x1A4CAF50),
    ),
    DashboardServiceStatusItem(
      label: 'Avaliações Pendentes',
      badgeLabel: '14 REQ',
      indicatorColor: Color(0xFFFC9039),
      badgeColor: Color(0xFFFC9039),
      badgeBackgroundColor: Color(0x1FFB7B02),
    ),
    DashboardServiceStatusItem(
      label: 'Disputas Ativas',
      badgeLabel: '2 CASOS',
      indicatorColor: Color(0xFFED1C24),
      badgeColor: Color(0xFFED1C24),
      badgeBackgroundColor: Color(0x26FFBDC0),
    ),
  ];

  static const List<DashboardPopularSubjectItem> popularSubjects = [
    DashboardPopularSubjectItem(
      label: 'Matemática',
      professorCountLabel: '145 Profs',
      icon: Icons.calculate_outlined,
      iconColor: Color(0xFF41A7D7),
      iconBackgroundColor: Color(0x2641A7D7),
    ),
    DashboardPopularSubjectItem(
      label: 'Ciências',
      professorCountLabel: '120 Profs',
      icon: Icons.hub_outlined,
      iconColor: Color(0xFFFB7B02),
      iconBackgroundColor: Color(0x1FFB7B02),
    ),
    DashboardPopularSubjectItem(
      label: 'Línguas',
      professorCountLabel: '98 Profs',
      icon: Icons.mail_outline_rounded,
      iconColor: Color(0xFFFF5A5F),
      iconBackgroundColor: Color(0x26FFBDC0),
    ),
  ];
}
