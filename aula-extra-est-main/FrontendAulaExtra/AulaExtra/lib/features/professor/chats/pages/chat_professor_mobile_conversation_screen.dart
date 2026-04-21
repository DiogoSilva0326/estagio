import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/communication/dtos/contact_user_summary_dto.dart';
import 'package:aula_extra/features/aluno/chats/sections/chat_mobile_conversation_section.dart';
import 'package:flutter/material.dart';

class ProfessorChatMobileConversationScreen extends StatelessWidget {
  const ProfessorChatMobileConversationScreen({
    super.key,
    required this.contact,
  });

  final ContactUserSummaryDto contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          const AppHeader(),
          Expanded(child: ChatMobileConversationSection(contact: contact)),
        ],
      ),
    );
  }
}
