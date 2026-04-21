import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/components/header/variants/header_aluno.dart';
import 'package:aula_extra/core/data/communication/dtos/contact_user_summary_dto.dart';
import 'package:aula_extra/features/aluno/chats/sections/chat_mobile_conversation_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class ChatMobileConversationScreen extends StatelessWidget {
  const ChatMobileConversationScreen({super.key, required this.contact});

  final ContactUserSummaryDto contact;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Column(
        children: [
          AppHeader(
            headerAlunoActiveItem: HeaderAlunoItem.recursos,
            onRegisterTap: () =>
                Navigator.of(context).pushNamed(Routes.registerStudent),
            onLoginTap: () => Navigator.of(context).pushNamed(Routes.login),
            onLogoTap: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(Routes.home, (route) => false),
          ),
          Expanded(child: ChatMobileConversationSection(contact: contact)),
        ],
      ),
    );
  }
}
