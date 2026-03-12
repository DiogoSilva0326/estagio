import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_colors.dart';
import 'package:flutter/material.dart';

/// Modelo de card de aula apresentado no calendário do professor.
///
/// Onde é usado:
/// - Em `lib/features/professor/calendario/` para renderizar a lista de próximas aulas.
class ProfessorAulaCardData {
  const ProfessorAulaCardData({
    required this.initials,
    required this.color,
    required this.studentName,
    required this.subject,
    required this.weekdayAndDate,
    required this.timeRange,
  });

  final String initials;
  final Color color;
  final String studentName;
  final String subject;
  final String weekdayAndDate;
  final String timeRange;
}

/// Dados fake do calendário do professor (protótipo/dev).
///
/// Onde é usado:
/// - Em `lib/features/professor/calendario/` enquanto não há dados reais via API.
class CalendarioProfessorMockData {
  const CalendarioProfessorMockData._();

  /// Lista de próximas aulas de exemplo.
  static const List<ProfessorAulaCardData> proximasAulas = [
    ProfessorAulaCardData(
      initials: 'JS',
      color: CalendarioProfessorColors.badgeBlue,
      studentName: 'João Silva',
      subject: 'Matemática',
      weekdayAndDate: 'Segunda, 27 Jan',
      timeRange: '14:30 - 15:30',
    ),
    ProfessorAulaCardData(
      initials: 'MS',
      color: CalendarioProfessorColors.badgeGreen,
      studentName: 'Maria Santos',
      subject: 'Física',
      weekdayAndDate: 'Segunda, 27 Jan',
      timeRange: '16:00 - 17:00',
    ),
    ProfessorAulaCardData(
      initials: 'PC',
      color: CalendarioProfessorColors.badgeOrange,
      studentName: 'Pedro Costa',
      subject: 'Inglês',
      weekdayAndDate: 'Terça, 28 Jan',
      timeRange: '10:00 - 11:00',
    ),
    ProfessorAulaCardData(
      initials: 'AR',
      color: CalendarioProfessorColors.badgeBlue,
      studentName: 'Ana Rodrigues',
      subject: 'Matemática',
      weekdayAndDate: 'Terça, 28 Jan',
      timeRange: '15:00 - 16:00',
    ),
  ];
}
