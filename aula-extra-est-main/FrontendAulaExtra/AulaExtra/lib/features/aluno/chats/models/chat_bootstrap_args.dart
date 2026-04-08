class ChatBootstrapArgs {
  const ChatBootstrapArgs({
    required this.contactUserId,
    this.contactName,
    this.contactUsername,
  });

  final String contactUserId;
  final String? contactName;
  final String? contactUsername;
}
