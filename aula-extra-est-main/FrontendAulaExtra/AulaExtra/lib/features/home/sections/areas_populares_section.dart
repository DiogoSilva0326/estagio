import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class AreasPopularesSection extends StatefulWidget {
  const AreasPopularesSection({super.key});

  @override
  State<AreasPopularesSection> createState() => _AreasPopularesSectionState();
}

class _AreasPopularesSectionState extends State<AreasPopularesSection> {
  final EducationService _educationService = EducationService();
  late final Future<List<AreaDto>> _areasFuture = _loadAreas();

  Future<List<AreaDto>> _loadAreas() async {
    final areas = await _educationService.getPublicAreas();
    final normalized = areas
        .where((area) => area.nome.trim().isNotEmpty)
        .toList(growable: false);

    normalized.sort(
      (left, right) =>
          left.nome.toLowerCase().compareTo(right.nome.toLowerCase()),
    );

    return normalized.take(8).toList(growable: false);
  }

  String _subtitleFor(AreaDto area) {
    if (area.professorCount == 1) {
      return '1 professor disponível';
    }
    return '${area.professorCount} professores disponíveis';
  }

  String _iconAssetFor(String areaName) {
    final normalized = areaName.trim().toLowerCase();
    if (normalized.contains('mat')) return HomeAssets.areaMatematica;
    if (normalized.contains('ci') ||
        normalized.contains('bio') ||
        normalized.contains('fis') ||
        normalized.contains('quim')) {
      return HomeAssets.areaCiencias;
    }
    if (normalized.contains('ling') ||
        normalized.contains('ingl') ||
        normalized.contains('portugu')) {
      return HomeAssets.areaLinguas;
    }
    if (normalized.contains('liter')) return HomeAssets.areaLiteratura;
    if (normalized.contains('program') ||
        normalized.contains('inform') ||
        normalized.contains('tec')) {
      return HomeAssets.areaProgramacao;
    }
    if (normalized.contains('geo') || normalized.contains('hist')) {
      return HomeAssets.areaGeografia;
    }
    if (normalized.contains('mús') || normalized.contains('mus')) {
      return HomeAssets.areaMusica;
    }
    if (normalized.contains('arte') || normalized.contains('design')) {
      return HomeAssets.areaArtes;
    }

    const fallbackAssets = <String>[
      HomeAssets.areaMatematica,
      HomeAssets.areaCiencias,
      HomeAssets.areaLinguas,
      HomeAssets.areaLiteratura,
      HomeAssets.areaProgramacao,
      HomeAssets.areaGeografia,
      HomeAssets.areaMusica,
      HomeAssets.areaArtes,
    ];

    final hash = normalized.runes.fold<int>(0, (sum, rune) => sum + rune);
    return fallbackAssets[hash % fallbackAssets.length];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 855,
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text(
            'Áreas Populares',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Escolhe entre uma vasta gama de áreas lecionadas\npor explicadores especialistas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAA31B),
            ),
          ),
          const SizedBox(height: 48),
          FutureBuilder<List<AreaDto>>(
            future: _areasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  width: 1319,
                  height: 420,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return SizedBox(
                  width: 1319,
                  child: Column(
                    children: [
                      const Text(
                        'Não foi possível carregar as áreas populares.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB42318),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF667085),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final areas = snapshot.data ?? const <AreaDto>[];
              if (areas.isEmpty) {
                return const SizedBox(
                  width: 1319,
                  child: Text(
                    'Ainda não existem áreas disponíveis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF667085),
                    ),
                  ),
                );
              }

              return SizedBox(
                width: 1319,
                child: Wrap(
                  spacing: 33,
                  runSpacing: 29,
                  children: [
                    for (final area in areas)
                      _AreaCard(
                        width: 298,
                        title: area.nome.toUpperCase(),
                        subtitle: _subtitleFor(area),
                        iconAsset: _iconAssetFor(area.nome),
                      ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15C64),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30),
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.disciplinas),
              child: const Text(
                'Ver Todas as Áreas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({
    required this.width,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
  });

  final double width;
  final String title;
  final String subtitle;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 34,
            top: 121,
            child: _AreaText(title: title, subtitle: subtitle),
          ),
          Positioned(
            left: 34,
            top: 32,
            child: Image.asset(iconAsset, width: 64, height: 63),
          ),
        ],
      ),
    );
  }
}

class _AreaText extends StatelessWidget {
  const _AreaText({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 224,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Color(0x80000000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
