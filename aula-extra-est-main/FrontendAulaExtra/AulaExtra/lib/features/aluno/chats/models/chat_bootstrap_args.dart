class ChatBootstrapArgs {
  const ChatBootstrapArgs({
    required this.contactUserId,
    this.contactName,
    this.contactUsername,
    this.initialMessage,
  });

  final String contactUserId;
  final String? contactName;
  final String? contactUsername;
  final String? initialMessage;
}
