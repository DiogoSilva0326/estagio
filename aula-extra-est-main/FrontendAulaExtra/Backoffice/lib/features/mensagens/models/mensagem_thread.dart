enum MensagemThreadType { alunoExplicador, suporte }

enum MensagemSenderRole { aluno, explicador, suporte, sistema }

class MensagemEntry {
  const MensagemEntry({
    required this.text,
    required this.timeLabel,
    required this.isIncoming,
    required this.senderRole,
  });

  final String text;
  final String timeLabel;
  final bool isIncoming;
  final MensagemSenderRole senderRole;
}

class MensagemThread {
  const MensagemThread({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.avatarInitials,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.type,
    required this.messages,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String avatarInitials;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final MensagemThreadType type;
  final List<MensagemEntry> messages;
}
