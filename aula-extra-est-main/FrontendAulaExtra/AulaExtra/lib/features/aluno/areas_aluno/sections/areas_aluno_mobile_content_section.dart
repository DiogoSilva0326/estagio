import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_mobile_layout.dart';
import 'package:aula_extra/features/aluno/areas_aluno/models/area_overview.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/areas_aluno_mobile_area_card.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/areas_aluno_mobile_catalog_card.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/areas_aluno_mobile_chip.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/areas_aluno_mobile_promo_card.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/areas_aluno_mobile_rating_card.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/areas_aluno_mobile_search_bar.dart';
import 'package:flutter/material.dart';

class AreasAlunoMobileCatalogItem {
  const AreasAlunoMobileCatalogItem({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String imageAsset;
}

class AreasAlunoMobileContentSection extends StatelessWidget {
  const AreasAlunoMobileContentSection({
    super.key,
    required this.loading,
    required this.error,
    required this.overviews,
    required this.popularAreas,
    required this.popularFilterOptions,
    required this.selectedPopularFilter,
    required this.searchController,
    required this.onRetry,
    required this.onViewDetails,
    required this.onMarkLesson,
    required this.onAddArea,
    required this.onPopularFilterChanged,
    required this.onPopularSearchChanged,
    required this.onPopularAreaTap,
    required this.onExploreTutors,
    required this.onBecomeTeacher,
  });

  final bool loading;
  final String? error;
  final List<AreaOverview> overviews;
  final List<AreasAlunoMobileCatalogItem> popularAreas;
  final List<String> popularFilterOptions;
  final String selectedPopularFilter;
  final TextEditingController searchController;
  final VoidCallback onRetry;
  final void Function(AreaOverview area) onViewDetails;
  final void Function(AreaOverview area) onMarkLesson;
  final VoidCallback onAddArea;
  final ValueChanged<String> onPopularFilterChanged;
  final ValueChanged<String> onPopularSearchChanged;
  final void Function(AreasAlunoMobileCatalogItem area) onPopularAreaTap;
  final VoidCallback onExploreTutors;
  final VoidCallback onBecomeTeacher;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AreasAlunoMobileLayout.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AreasAlunoMobileLayout.horizontalPadding,
          AreasAlunoMobileLayout.verticalPadding,
          AreasAlunoMobileLayout.horizontalPadding,
          32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Minhas Áreas',
              style: TextStyle(
                fontSize: 34,
                height: 1.08,
                fontWeight: FontWeight.w700,
                color: AreasAlunoMobileLayout.titleColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gerencie suas disciplinas e acompanhe seu progresso',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: AreasAlunoMobileLayout.bodyColor,
              ),
            ),
            const SizedBox(height: AreasAlunoMobileLayout.sectionSpacing),
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              _ErrorCard(message: error!, onRetry: onRetry)
            else if (overviews.isEmpty)
              _EmptyCard(onAddArea: onAddArea)
            else
              for (var index = 0; index < overviews.length; index++) ...[
                AreasAlunoMobileAreaCard(
                  area: overviews[index],
                  onViewDetails: () => onViewDetails(overviews[index]),
                  onMarkLesson: () => onMarkLesson(overviews[index]),
                ),
                if (index != overviews.length - 1) const SizedBox(height: 16),
              ],
            const SizedBox(height: AreasAlunoMobileLayout.sectionSpacing),
            const AreasAlunoMobileRatingCard(),
            const SizedBox(height: 16),
            AreasAlunoMobilePromoCard(
              title: 'Queres Aprender?',
              description:
                  'Encontra explicadores especialistas em qualquer disciplina e começa a aprender hoje',
              buttonLabel: 'Começar',
              onPressed: onExploreTutors,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFC9039),
                  Color(0xFFFC9237),
                  Color(0xFFFC9335),
                  Color(0xFFFC9533),
                  Color(0xFFFB9631),
                  Color(0xFFFB982F),
                  Color(0xFFFB9A2D),
                  Color(0xFFFB9B2B),
                  Color(0xFFFB9D28),
                  Color(0xFFFB9E25),
                  Color(0xFFFAA022),
                  Color(0xFFFAA11F),
                  Color(0xFFFAA31B),
                ],
              ),
              buttonTextColor: const Color(0xFFFC9039),
              borderRadius: 20,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Helvetica Neue',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
              descriptionStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Helvetica Neue',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: -0.15,
              ),
              buttonHeight: 48,
              buttonWidth: 113.47,
              buttonPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 12,
              ),
              buttonBorderRadius: 10,
            ),
            const SizedBox(height: 16),
            AreasAlunoMobilePromoCard(
              title: 'Queres Ensinar?',
              description:
                  'Junta-te à nossa comunidade de explicadores e partilha o teu conhecimento',
              buttonLabel: 'Inscrever',
              onPressed: onBecomeTeacher,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF15C64),
                  Color(0xFFF26062),
                  Color(0xFFF36460),
                  Color(0xFFF4685E),
                  Color(0xFFF46C5B),
                  Color(0xFFF57059),
                  Color(0xFFF67456),
                  Color(0xFFF77753),
                  Color(0xFFF87B50),
                  Color(0xFFF87F4D),
                  Color(0xFFF9824A),
                  Color(0xFFFA8646),
                  Color(0xFFFB8942),
                  Color(0xFFFB8D3E),
                  Color(0xFFFC9039),
                ],
              ),
              buttonTextColor: const Color(0xFFF15C64),
              borderRadius: 20,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Helvetica Neue',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
              descriptionStyle: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Helvetica Neue',
                fontWeight: FontWeight.w400,
                height: 1.43,
                letterSpacing: -0.15,
              ),
              buttonHeight: 48,
              buttonWidth: 113.16,
              buttonPadding: const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 12,
              ),
              buttonBorderRadius: 10,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddArea,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Adicionar Nova Área'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: Color(0xFFD1D5DC), width: 1.4),
                  foregroundColor: AreasAlunoMobileLayout.bodyColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AreasAlunoMobileLayout.sectionSpacing),
            const Text(
              'Áreas Populares',
              style: TextStyle(
                fontSize: 30,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: AreasAlunoMobileLayout.titleColor,
              ),
            ),
            const SizedBox(height: 14),
            AreasAlunoMobileSearchBar(
              controller: searchController,
              onChanged: onPopularSearchChanged,
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (
                    var index = 0;
                    index < popularFilterOptions.length;
                    index++
                  ) ...[
                    AreasAlunoMobileChip(
                      label: popularFilterOptions[index],
                      selected:
                          popularFilterOptions[index] == selectedPopularFilter,
                      onTap: () =>
                          onPopularFilterChanged(popularFilterOptions[index]),
                    ),
                    if (index != popularFilterOptions.length - 1)
                      const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (popularAreas.isEmpty)
              const Text(
                'Não existem áreas para mostrar com este filtro.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AreasAlunoMobileLayout.bodyColor,
                ),
              )
            else
              for (var index = 0; index < popularAreas.length; index++) ...[
                AreasAlunoMobileCatalogCard(
                  title: popularAreas[index].name,
                  imageAsset: popularAreas[index].imageAsset,
                  onTap: () => onPopularAreaTap(popularAreas[index]),
                ),
                if (index != popularAreas.length - 1)
                  const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD5D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(color: Color(0xFFB42318), fontSize: 14),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.onAddArea});

  final VoidCallback onAddArea;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ainda não tens áreas selecionadas.',
            style: TextStyle(
              fontSize: 18,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: AreasAlunoMobileLayout.titleColor,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Adiciona uma nova área para começares a acompanhar disciplinas e marcar aulas.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AreasAlunoMobileLayout.bodyColor,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onAddArea,
            child: const Text('Adicionar área'),
          ),
        ],
      ),
    );
  }
}
