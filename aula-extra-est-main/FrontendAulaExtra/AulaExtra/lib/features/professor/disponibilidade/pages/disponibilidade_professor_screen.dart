import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/professor/disponibilidade/pages/disponibilidade_professor_mobile_page.dart';
import 'package:aula_extra/features/professor/disponibilidade/sections/disponibilidade_professor_content_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DisponibilidadeProfessorScreen extends StatelessWidget {
  const DisponibilidadeProfessorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return const DisponibilidadeProfessorMobilePage();
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
          const SliverToBoxAdapter(
            child: DisponibilidadeProfessorContentSection(),
          ),
          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }
}
