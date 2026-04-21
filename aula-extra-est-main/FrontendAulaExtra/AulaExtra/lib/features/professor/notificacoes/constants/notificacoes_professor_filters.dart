enum NotificacoesProfessorFiltro { todas, naoLidas, aulas, tarefas, mensagens }

extension NotificacoesProfessorFiltroLabel on NotificacoesProfessorFiltro {
  String get label {
    switch (this) {
      case NotificacoesProfessorFiltro.todas:
        return 'Todas';
      case NotificacoesProfessorFiltro.naoLidas:
        return 'Não lidas';
      case NotificacoesProfessorFiltro.aulas:
        return 'Aulas';
      case NotificacoesProfessorFiltro.tarefas:
        return 'Tarefas';
      case NotificacoesProfessorFiltro.mensagens:
        return 'Mensagens';
    }
  }
}
