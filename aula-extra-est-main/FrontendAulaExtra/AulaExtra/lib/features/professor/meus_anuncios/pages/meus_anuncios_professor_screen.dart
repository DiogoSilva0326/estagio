import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/professor/meus_anuncios/pages/meus_anuncios_professor_mobile_page.dart';
import 'package:aula_extra/features/professor/meus_anuncios/sections/meus_anuncios_professor_content_section.dart';
import 'package:flutter/material.dart';

class MeusAnunciosProfessorScreen extends StatelessWidget {
  const MeusAnunciosProfessorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return const MeusAnunciosProfessorMobilePage();
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
            child: MeusAnunciosProfessorContentSection(),
          ),
          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }
}
