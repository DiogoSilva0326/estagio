import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/professor/avaliacoes/sections/avaliacoes_professor_content_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvaliacoesProfessorScreen extends StatelessWidget {
  const AvaliacoesProfessorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isTeacher = role == Role.teacher;

    if (!isTeacher) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
      });
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
          const SliverToBoxAdapter(child: AvaliacoesProfessorContentSection()),
          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }
}
