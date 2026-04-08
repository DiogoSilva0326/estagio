import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:flutter/material.dart';

/// Modelo e dados mock usados no ecrã **Meus Alunos** (Professor).
///
/// Onde é usado:
/// - `lib/features/professor/meus_alunos/` (lista/grid de cards)
/// - Durante desenvolvimento, antes de existir integração real com a API.
class ProfessorAlunoCardData {
  const ProfessorAlunoCardData({
    required this.name,
    required this.avatarUrl,
    required this.subjects,
    required this.lastLessonDate,
    required this.progress,
  });

  final String name;
  final String avatarUrl;
  final List<String> subjects;
  final String lastLessonDate;
  final double progress;

  /// Progresso em percentagem (0..100), derivado de `progress` (0.0..1.0).
  int get progressPercent => (progress * 100).round().clamp(0, 100);
}

class MeusAlunosProfessorMockData {
  const MeusAlunosProfessorMockData._();

  /// Lista mock de alunos (para renderização dos cards).
  static const List<ProfessorAlunoCardData> alunos = [
    ProfessorAlunoCardData(
      name: 'João Silva',
      avatarUrl: '',
      subjects: ['Matemática'],
      lastLessonDate: '20 Jan 2026',
      progress: 0.80,
    ),
    ProfessorAlunoCardData(
      name: 'Maria Santos',
      avatarUrl: '',
      subjects: ['Física', 'Química'],
      lastLessonDate: '22 Jan 2026',
      progress: 0.65,
    ),
    ProfessorAlunoCardData(
      name: 'Pedro Costa',
      avatarUrl: '',
      subjects: ['Inglês'],
      lastLessonDate: '23 Jan 2026',
      progress: 0.90,
    ),
    ProfessorAlunoCardData(
      name: 'Ana Rodrigues',
      avatarUrl: '',
      subjects: ['Matemática'],
      lastLessonDate: '24 Jan 2026',
      progress: 0.75,
    ),
    ProfessorAlunoCardData(
      name: 'Carlos Ferreira',
      avatarUrl: '',
      subjects: ['Física'],
      lastLessonDate: '25 Jan 2026',
      progress: 0.70,
    ),
    ProfessorAlunoCardData(
      name: 'Sofia Oliveira',
      avatarUrl: '',
      subjects: ['Inglês', 'Matemática'],
      lastLessonDate: '26 Jan 2026',
      progress: 0.85,
    ),
  ];
}

/// Devolve uma cor consistente para a disciplina.
///
/// Nota: usado para colorir chips/badges de disciplinas nos cards.
Color subjectColor(String subject) {
  return switch (subject) {
    'Matemática' => MeusAlunosProfessorColors.blue,
    'Física' => MeusAlunosProfessorColors.green,
    'Química' => MeusAlunosProfessorColors.purple,
    'Inglês' => MeusAlunosProfessorColors.orangeBadge,
    _ => MeusAlunosProfessorColors.blue,
  };
}
