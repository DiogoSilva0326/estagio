import 'package:aula_extra/features/aluno/chats/constants/chats_constants.dart';
import 'package:flutter/material.dart';

class ChatsMobileIntro extends StatelessWidget {
  const ChatsMobileIntro({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ChatsConstants.mobileTitleStyle),
        const SizedBox(height: 8),
        Text(subtitle, style: ChatsConstants.mobileSubtitleStyle),
      ],
    );
  }
}
