import '../models/mensagem_thread.dart';

class MensagensMockData {
  const MensagensMockData._();

  static const List<MensagemThread> threads = [
    MensagemThread(
      id: 'conv-ana',
      title: 'Ana Rodrigues',
      subtitle: 'Explicadora de Matemática',
      avatarInitials: 'A',
      lastMessage: 'A aula de hoje foi ótima!',
      lastMessageTime: '14:30',
      unreadCount: 2,
      type: MensagemThreadType.alunoExplicador,
      messages: [
        MensagemEntry(
          text:
              'Olá Ana, tive algumas dúvidas no exercício 4 da ficha de ontem. Podemos rever na próxima aula?',
          timeLabel: '14:20',
          isIncoming: true,
          senderRole: MensagemSenderRole.aluno,
        ),
        MensagemEntry(
          text:
              'Claro João! Não te preocupes, separamos os primeiros 15 minutos para rever isso. A aula de hoje foi ótima!',
          timeLabel: '14:30',
          isIncoming: false,
          senderRole: MensagemSenderRole.explicador,
        ),
      ],
    ),
    MensagemThread(
      id: 'conv-joao',
      title: 'João Silva',
      subtitle: 'Aluno · Física e Química',
      avatarInitials: 'J',
      lastMessage: 'Podes enviar os slides?',
      lastMessageTime: 'Ontem',
      type: MensagemThreadType.alunoExplicador,
      messages: [
        MensagemEntry(
          text: 'Podes enviar os slides?',
          timeLabel: 'Ontem · 18:42',
          isIncoming: true,
          senderRole: MensagemSenderRole.aluno,
        ),
      ],
    ),
    MensagemThread(
      id: 'conv-suporte',
      title: 'Suporte AulaExtra',
      subtitle: 'Equipa interna',
      avatarInitials: 'S',
      lastMessage: 'Ticket #2381 atualizado com sucesso.',
      lastMessageTime: 'Ontem',
      unreadCount: 1,
      type: MensagemThreadType.suporte,
      messages: [
        MensagemEntry(
          text: 'Ticket #2381 atualizado com sucesso.',
          timeLabel: 'Ontem · 10:02',
          isIncoming: false,
          senderRole: MensagemSenderRole.suporte,
        ),
      ],
    ),
  ];
}
