class MessageDto {
  final String idMessage;
  final String senderUserId;
  final String receiverUserId;
  final String messageContent;
  final bool isRead;
  final DateTime? sentAt;

  MessageDto({
    required this.idMessage,
    required this.senderUserId,
    required this.receiverUserId,
    required this.messageContent,
    required this.isRead,
    this.sentAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      idMessage: json['idMessage']?.toString() ?? '',
      senderUserId: json['senderUserId']?.toString() ?? '',
      receiverUserId: json['receiverUserId']?.toString() ?? '',
      messageContent: json['messageContent'] ?? '',
      isRead: json['isRead'] ?? false,
      sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMessage': idMessage, 
      'senderUserId': senderUserId,
      'receiverUserId': receiverUserId,
      'messageContent': messageContent,
      'isRead': isRead,
      'sentAt': sentAt?.toIso8601String(),
    };
  }
}