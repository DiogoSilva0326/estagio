import 'package:aula_extra/features/professor/calendario/constants/calendario_professor_colors.dart';
import 'package:flutter/material.dart';

class ProfessorAulaCardData {
  const ProfessorAulaCardData({
    this.idLesson = '', // 💡 NOVO: Guardar o ID da aula para podermos apagar!
    required this.initials,
    required this.color,
    required this.studentName,
    required this.subject,
    required this.weekdayAndDate,
    required this.timeRange,
  });

  final String idLesson;
  final String initials;
  final Color color;
  final String studentName;
  final String subject;
  final String weekdayAndDate;
  final String timeRange;
}

class CalendarioProfessorMockData {
  const CalendarioProfessorMockData._();

  static const List<ProfessorAulaCardData> proximasAulas = [
    ProfessorAulaCardData(
      idLesson: 'mock-1',
      initials: 'JS',
      color: CalendarioProfessorColors.badgeBlue,
      studentName: 'João Silva',
      subject: 'Matemática',
      weekdayAndDate: 'Segunda, 27 Jan',
      timeRange: '14:30 - 15:30',
    ),
    ProfessorAulaCardData(
      idLesson: 'mock-2',
      initials: 'MS',
      color: CalendarioProfessorColors.badgeGreen,
      studentName: 'Maria Santos',
      subject: 'Física',
      weekdayAndDate: 'Segunda, 27 Jan',
      timeRange: '16:00 - 17:00',
    ),
    ProfessorAulaCardData(
      idLesson: 'mock-3',
      initials: 'PC',
      color: CalendarioProfessorColors.badgeOrange,
      studentName: 'Pedro Costa',
      subject: 'Inglês',
      weekdayAndDate: 'Terça, 28 Jan',
      timeRange: '10:00 - 11:00',
    ),
    ProfessorAulaCardData(
      idLesson: 'mock-4',
      initials: 'AR',
      color: CalendarioProfessorColors.badgeBlue,
      studentName: 'Ana Rodrigues',
      subject: 'Matemática',
      weekdayAndDate: 'Terça, 28 Jan',
      timeRange: '15:00 - 16:00',
    ),
  ];
}