enum AvaliacoesProfessorTab { professor, aulas }

extension AvaliacoesProfessorTabLabel on AvaliacoesProfessorTab {
  String get label {
    switch (this) {
      case AvaliacoesProfessorTab.professor:
        return 'Professor';
      case AvaliacoesProfessorTab.aulas:
        return 'Aulas';
    }
  }

  String get mobileSummaryLabel {
    switch (this) {
      case AvaliacoesProfessorTab.professor:
        return 'Avaliação Média';
      case AvaliacoesProfessorTab.aulas:
        return 'Média das aulas';
    }
  }

  String get mobileCountLabel {
    switch (this) {
      case AvaliacoesProfessorTab.professor:
        return 'avaliações ao professor';
      case AvaliacoesProfessorTab.aulas:
        return 'avaliações às aulas';
    }
  }

  String get sectionTitle {
    switch (this) {
      case AvaliacoesProfessorTab.professor:
        return 'Avaliações feitas ao professor';
      case AvaliacoesProfessorTab.aulas:
        return 'Avaliações submetidas às aulas';
    }
  }
}
