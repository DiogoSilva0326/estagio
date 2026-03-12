import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_assets.dart';
import 'package:flutter/material.dart';

class AreaCategoryOption {
  const AreaCategoryOption({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageAsset,
    required this.gradientStart,
    required this.gradientEnd,
    required this.disciplines,
  });

  final String id;
  final String name;
  final String subtitle;
  final String imageAsset;
  final Color gradientStart;
  final Color gradientEnd;
  final List<String> disciplines;
}

const areaCategoryOptions = <AreaCategoryOption>[
  AreaCategoryOption(
    id: 'matematica',
    name: 'Matemática',
    subtitle: 'Área de Ciências Exatas',
    imageAsset: AreasAlunoAssets.matematica,
    gradientStart: Color(0xFF51A2FF),
    gradientEnd: Color(0xFF155DFC),
    disciplines: ['Álgebra', 'Geometria', 'Trigonometria', 'Cálculo', 'Estatística'],
  ),
  AreaCategoryOption(
    id: 'ciencias',
    name: 'Ciências',
    subtitle: 'Área de Ciências Naturais',
    imageAsset: AreasAlunoAssets.ciencias,
    gradientStart: Color(0xFF05DF72),
    gradientEnd: Color(0xFF00A63E),
    disciplines: ['Física', 'Química', 'Biologia', 'Geologia'],
  ),
  AreaCategoryOption(
    id: 'linguas',
    name: 'Línguas',
    subtitle: 'Área de Idiomas e Comunicação',
    imageAsset: AreasAlunoAssets.linguas,
    gradientStart: Color(0xFFC27AFF),
    gradientEnd: Color(0xFF9810FA),
    disciplines: ['Português', 'Inglês', 'Espanhol', 'Francês', 'Alemão'],
  ),
  AreaCategoryOption(
    id: 'humanidades',
    name: 'Humanidades',
    subtitle: 'Área de Ciências Humanas e Sociais',
    imageAsset: AreasAlunoAssets.ciencias,
    gradientStart: Color(0xFFFFB900),
    gradientEnd: Color(0xFFE17100),
    disciplines: ['História', 'Geografia', 'Filosofia', 'Sociologia', 'Economia'],
  ),
  AreaCategoryOption(
    id: 'artes',
    name: 'Artes',
    subtitle: 'Área de Artes e Criatividade',
    imageAsset: AreasAlunoAssets.ciencias,
    gradientStart: Color(0xFFFB64B6),
    gradientEnd: Color(0xFFE60076),
    disciplines: ['Artes Visuais', 'Música', 'Teatro', 'Dança', 'Design'],
  ),
  AreaCategoryOption(
    id: 'tecnologia',
    name: 'Tecnologia',
    subtitle: 'Área de Tecnologia e Informática',
    imageAsset: AreasAlunoAssets.ciencias,
    gradientStart: Color(0xFF00D3F2),
    gradientEnd: Color(0xFF0092B8),
    disciplines: ['Programação', 'Robótica', 'Informática', 'Multimédia', 'Redes'],
  ),
];
