import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/professor/meus_alunos/sections/meus_alunos_professor_content_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeusAlunosProfessorScreen extends StatelessWidget {
  const MeusAlunosProfessorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isTeacher = role == Role.teacher;

    if (!isTeacher) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
      });
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: 90,
              child: const AppHeader(),
            ),
          ),
          const SliverToBoxAdapter(child: MeusAlunosProfessorContentSection()),
          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }
}
