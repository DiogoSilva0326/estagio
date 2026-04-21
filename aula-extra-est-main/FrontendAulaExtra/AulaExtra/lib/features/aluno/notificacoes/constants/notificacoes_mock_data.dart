import 'package:flutter/material.dart';

/// Tipos de notificações suportados na UI do aluno.
///
/// Onde é usado:
/// - Em `lib/features/aluno/notificacoes/` para agrupar/renderizar diferentes
///   estilos/ícones conforme o tipo.
enum NotificacaoTipo { aula, tarefa, mensagem, avaliacao, pagamento }

/// Modelo de item de notificação apresentado na lista.
///
/// Onde é usado:
/// - Em `lib/features/aluno/notificacoes/` para renderizar cards/rows.
class NotificacaoItem {
  const NotificacaoItem({
    required this.id,
    required this.tipo,
    required this.title,
    required this.message,
    required this.timeLabel,
    required this.icon,
    required this.iconBackground,
    this.unread = false,
  });

  final String id;
  final NotificacaoTipo tipo;
  final String title;
  final String message;
  final String timeLabel;

  final IconData icon;
  final Color iconBackground;

  final bool unread;

  NotificacaoItem copyWith({bool? unread}) {
    return NotificacaoItem(
      id: id,
      tipo: tipo,
      title: title,
      message: message,
      timeLabel: timeLabel,
      icon: icon,
      iconBackground: iconBackground,
      unread: unread ?? this.unread,
    );
  }
}

/// Dados fake de notificações para preencher a UI durante prototipagem/dev.
///
/// Onde é usado:
/// - Em `lib/features/aluno/notificacoes/` enquanto não houver dados reais via API.
class NotificacoesMockData {
  const NotificacoesMockData._();

  /// Lista de notificações de exemplo.
  static const List<NotificacaoItem> items = [
    NotificacaoItem(
      id: 'aula-5-min',
      tipo: NotificacaoTipo.aula,
      title: 'Aula em 5 minutos',
      message: 'Sua aula de Matemática com João Silva começa em 5 minutos',
      timeLabel: 'Agora',
      icon: Icons.access_time_rounded,
      iconBackground: Color(0xFF00C950),
      unread: true,
    ),
    NotificacaoItem(
      id: 'tarefa-joao',
      tipo: NotificacaoTipo.tarefa,
      title: 'Nova tarefa de João Silva',
      message: 'Você recebeu uma nova tarefa: Exercícios de Álgebra',
      timeLabel: 'Há 15 min',
      icon: Icons.assignment_rounded,
      iconBackground: Color(0xFF2B7FFF),
      unread: true,
    ),
    NotificacaoItem(
      id: 'mensagem-maria',
      tipo: NotificacaoTipo.mensagem,
      title: 'Nova mensagem',
      message: 'Maria Santos enviou uma mensagem',
      timeLabel: 'Há 1 hora',
      icon: Icons.chat_bubble_rounded,
      iconBackground: Color(0xFFAD46FF),
      unread: true,
    ),
    NotificacaoItem(
      id: 'avaliar-ultima-aula',
      tipo: NotificacaoTipo.avaliacao,
      title: 'Avalie sua última aula',
      message: 'Que tal avaliar a aula com Pedro Costa?',
      timeLabel: 'Há 2 horas',
      icon: Icons.star_rounded,
      iconBackground: Color(0xFFF0B100),
    ),
    NotificacaoItem(
      id: 'aula-agendada',
      tipo: NotificacaoTipo.aula,
      title: 'Aula agendada',
      message: 'Sua aula de Física foi confirmada para amanhã às 10:00',
      timeLabel: 'Há 3 horas',
      icon: Icons.calendar_month_rounded,
      iconBackground: Color(0xFF00C950),
    ),
    NotificacaoItem(
      id: 'pagamento-confirmado',
      tipo: NotificacaoTipo.pagamento,
      title: 'Pagamento confirmado',
      message: 'Seu pagamento de 25€ foi processado com sucesso',
      timeLabel: 'Ontem',
      icon: Icons.payments_rounded,
      iconBackground: Color(0xFFFF6900),
    ),
  ];
}
