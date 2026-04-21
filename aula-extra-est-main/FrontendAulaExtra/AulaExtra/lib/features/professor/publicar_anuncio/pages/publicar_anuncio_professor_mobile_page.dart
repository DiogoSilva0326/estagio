import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/sections/publicar_anuncio_professor_content_section.dart';
import 'package:flutter/material.dart';

class PublicarAnuncioProfessorMobilePage extends StatelessWidget {
  const PublicarAnuncioProfessorMobilePage({super.key, this.initialAd});

  final ProfessorAdDto? initialAd;

  @override
  Widget build(BuildContext context) {
    return ProfessorMobilePageScaffold(
      child: PublicarAnuncioProfessorContentSection(
        initialAd: initialAd,
        isMobile: true,
      ),
    );
  }
}
