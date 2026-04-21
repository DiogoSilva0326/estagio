import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/professor/chats/pages/chats_professor_mobile_page.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/professor/chats/sections/chats_professor_content_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsProfessorScreen extends StatelessWidget {
  const ChatsProfessorScreen({
    super.key,
    this.initialStudentUsername,
    this.initialStudentName,
  });

  final String? initialStudentUsername;
  final String? initialStudentName;

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isTeacher = role == Role.teacher;
    final rawArgs = ModalRoute.of(context)?.settings.arguments;
    final args = rawArgs is Map
        ? Map<String, dynamic>.from(rawArgs)
        : const <String, dynamic>{};
    final resolvedUsername =
        initialStudentUsername ??
        args['studentUsername']?.toString() ??
        args['studentId']?.toString();
    final resolvedName = initialStudentName ?? args['studentName']?.toString();

    if (!isTeacher) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
      });
    }

    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return ChatsProfessorMobilePage(
        initialStudentUsername: resolvedUsername,
        initialStudentName: resolvedName,
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: AppHeader.resolvedHeight(context),
              child: const AppHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: ChatsProfessorContentSection(
              initialStudentUsername: resolvedUsername,
              initialStudentName: resolvedName,
            ),
          ),
          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }
}
