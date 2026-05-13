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
    required this.category,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String category;
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
              'Apoios & Áreas',
              style: TextStyle(
                fontSize: 34,
                height: 1.08,
                fontWeight: FontWeight.w700,
                color: AreasAlunoMobileLayout.titleColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gerencie as suas disciplinas, tutorias e sessões de psicologia.',
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
            
            const Text(
              'Explorar Catálogo',
              style: TextStyle(
                fontSize: 28,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: AreasAlunoMobileLayout.titleColor,
              ),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  for (var index = 0; index < popularFilterOptions.length; index++) ...[
                    AreasAlunoMobileChip(
                      label: popularFilterOptions[index],
                      selected: popularFilterOptions[index] == selectedPopularFilter,
                      onTap: () => onPopularFilterChanged(popularFilterOptions[index]),
                    ),
                    if (index != popularFilterOptions.length - 1) const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (popularAreas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: const Text(
                  'Não existem apoios disponíveis nesta categoria.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AreasAlunoMobileLayout.bodyColor),
                ),
              )
            else
              for (var index = 0; index < popularAreas.length; index++) ...[
                AreasAlunoMobileCatalogCard(
                  title: popularAreas[index].name,
                  category: popularAreas[index].category,
                  imageAsset: popularAreas[index].imageAsset,
                  onTap: () => onPopularAreaTap(popularAreas[index]),
                ),
                if (index != popularAreas.length - 1) const SizedBox(height: 12),
              ],
            
            const SizedBox(height: AreasAlunoMobileLayout.sectionSpacing),
            const AreasAlunoMobileRatingCard(),
            const SizedBox(height: 16),
            AreasAlunoMobilePromoCard(
              title: 'Precisa de Ajuda?',
              description: 'Encontre especialistas prontos a ajudar no seu desenvolvimento escolar ou pessoal.',
              buttonLabel: 'Começar',
              onPressed: onExploreTutors,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFC9039), Color(0xFFFAA31B)],
              ),
              buttonTextColor: const Color(0xFFFC9039),
              borderRadius: 20,
              padding: const EdgeInsets.all(24),
              titleStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
              descriptionStyle: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
              buttonHeight: 48,
              buttonWidth: 120,
              buttonPadding: const EdgeInsets.symmetric(vertical: 12),
              buttonBorderRadius: 10,
            ),
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
          Text(message, style: const TextStyle(color: Color(0xFFB42318), fontSize: 14)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(Icons.explore_outlined, size: 40, color: Color(0xFF9CA3AF)),
          const SizedBox(height: 16),
          const Text(
            'Nenhum apoio selecionado.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AreasAlunoMobileLayout.titleColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione uma área para começar a gerir sessões.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: AreasAlunoMobileLayout.bodyColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onAddArea, child: const Text('Adicionar área')),
        ],
      ),
    );
  }
}