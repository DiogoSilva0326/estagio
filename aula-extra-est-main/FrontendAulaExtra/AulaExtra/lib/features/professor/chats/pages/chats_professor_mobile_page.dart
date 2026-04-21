import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/chats/sections/chats_professor_content_section.dart';
import 'package:flutter/material.dart';

class ChatsProfessorMobilePage extends StatelessWidget {
  const ChatsProfessorMobilePage({
    super.key,
    this.initialStudentUsername,
    this.initialStudentName,
  });

  final String? initialStudentUsername;
  final String? initialStudentName;

  @override
  Widget build(BuildContext context) {
    return ProfessorMobilePageScaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      footerTopSpacing: 8,
      child: ChatsProfessorContentSection(
        isMobile: true,
        initialStudentUsername: initialStudentUsername,
        initialStudentName: initialStudentName,
      ),
    );
  }
}
