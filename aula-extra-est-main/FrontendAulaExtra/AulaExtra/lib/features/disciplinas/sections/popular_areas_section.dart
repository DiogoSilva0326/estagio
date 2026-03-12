import 'package:aula_extra/features/disciplinas/models/subject_area.dart';
import 'package:aula_extra/features/disciplinas/widgets/subject_card.dart';
import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:flutter/material.dart';

class PopularAreasSection extends StatelessWidget {
  const PopularAreasSection({super.key});

  static const List<SubjectArea> _areas = [
    SubjectArea(
      title: 'MATEMÁTICA',
      tutorsText: '201 explicadores',
      imageAsset: HomeAssets.areaMatematica,
      dotColor: Color(0xFF3B94EF),
    ),
    SubjectArea(
      title: 'CIÊNCIAS',
      tutorsText: '98 explicadores',
      imageAsset: HomeAssets.areaCiencias,
      dotColor: Color(0xFF45AB61),
    ),
    SubjectArea(
      title: 'LÍNGUAS',
      tutorsText: '506 explicadores',
      imageAsset: HomeAssets.areaLinguas,
      dotColor: Color(0xFFFC9039),
    ),
    SubjectArea(
      title: 'LITERATURA',
      tutorsText: '88 explicadores',
      imageAsset: HomeAssets.areaLiteratura,
      dotColor: Color(0xFF9B59B6),
    ),
    SubjectArea(
      title: 'PROGRAMAÇÃO',
      tutorsText: '304 explicadores',
      imageAsset: HomeAssets.areaProgramacao,
      dotColor: Color(0xFFE74C3C),
    ),
    SubjectArea(
      title: 'GEOGRAFIA',
      tutorsText: '105 explicadores',
      imageAsset: HomeAssets.areaGeografia,
      dotColor: Color(0xFFFFC505),
    ),
    SubjectArea(
      title: 'MÚSICA',
      tutorsText: '45 explicadores',
      imageAsset: HomeAssets.areaMusica,
      dotColor: Color(0xFFFF8CEF),
    ),
    SubjectArea(
      title: 'ARTES',
      tutorsText: '67 explicadores',
      imageAsset: HomeAssets.areaArtes,
      dotColor: Color(0xFFDAF508),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Áreas Populares',
          style: TextStyle(
            fontSize: 30.638,
            height: 1.333,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 30.638),
        SizedBox(
          width: 949.787,
          child: Wrap(
            spacing: 30.638,
            runSpacing: 30.638,
            children: [
              for (final area in _areas)
                SubjectCard(
                  title: area.title,
                  subtitle: area.tutorsText,
                  imageAsset: area.imageAsset,
                  dotColor: area.dotColor,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
