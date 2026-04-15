import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/models/publicar_anuncio_professor_args.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/sections/publicar_anuncio_professor_content_section.dart';
import 'package:flutter/material.dart';

class PublicarAnuncioProfessorScreen extends StatelessWidget {
  const PublicarAnuncioProfessorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final args = routeArgs is PublicarAnuncioProfessorArgs ? routeArgs : null;

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
            child: PublicarAnuncioProfessorContentSection(initialAd: args?.ad),
          ),
          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }
}
