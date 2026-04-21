import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/features/disciplinas/constants/disciplinas_mobile_layout.dart';
import 'package:aula_extra/features/disciplinas/utils/area_visuals.dart';
import 'package:aula_extra/features/disciplinas/widgets/disciplinas_mobile_area_card.dart';
import 'package:aula_extra/features/disciplinas/widgets/disciplinas_mobile_cta_section.dart';
import 'package:aula_extra/features/disciplinas/widgets/disciplinas_mobile_ratings_banner.dart';
import 'package:aula_extra/features/disciplinas/widgets/disciplinas_mobile_search_bar.dart';
import 'package:aula_extra/features/disciplinas/widgets/disciplinas_mobile_subject_card.dart';
import 'package:aula_extra/features/explicadores/pages/explicadores_screen.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class DisciplinasMobileContentSection extends StatelessWidget {
  const DisciplinasMobileContentSection({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.areas,
    required this.disciplinas,
    required this.selectedArea,
    required this.onAreaSelected,
    required this.onClearArea,
    required this.loading,
    this.error,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<AreaDto> areas;
  final List<DisciplinaDto> disciplinas;
  final AreaDto? selectedArea;
  final ValueChanged<String> onAreaSelected;
  final VoidCallback onClearArea;
  final bool loading;
  final String? error;

  String _formatCount(
    int count, {
    required String singular,
    required String plural,
  }) {
    return count == 1 ? '1 $singular' : '$count $plural';
  }

  @override
  Widget build(BuildContext context) {
    final showingDisciplinas = selectedArea != null;
    final chipAreas = areas.take(8).toList(growable: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DisciplinasMobileLayout.pageHorizontalPadding,
        10,
        DisciplinasMobileLayout.pageHorizontalPadding,
        32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderBlock(),
          const SizedBox(height: 18),
          DisciplinasMobileSearchBar(
            controller: searchController,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 20),
          _AreaChipsRow(
            areas: chipAreas,
            selectedAreaId: selectedArea?.idArea,
            onAreaSelected: onAreaSelected,
          ),
          const SizedBox(height: 22),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: CircularProgressIndicator(),
              ),
            )
          else if (error != null)
            _MessageCard(message: error!)
          else ...[
            if (showingDisciplinas)
              _SelectedAreaHeader(
                area: selectedArea!,
                disciplinaCount: disciplinas.length,
                onBackTap: onClearArea,
              )
            else
              const _ListHeader(
                title: 'Explora por áreas',
                subtitle:
                    'Seleciona uma área para veres as disciplinas disponíveis.',
              ),
            const SizedBox(height: 18),
            if (showingDisciplinas && disciplinas.isEmpty)
              const _MessageCard(
                message: 'Não encontrámos disciplinas associadas a esta área.',
              )
            else
              Column(
                children: [
                  if (showingDisciplinas)
                    for (final disciplina in disciplinas) ...[
                      Builder(
                        builder: (context) {
                          final visuals = getAreaVisuals(
                            disciplina.areaNome ?? selectedArea!.nome,
                          );
                          return DisciplinasMobileSubjectCard(
                            title: disciplina.nome,
                            subtitle: _formatCount(
                              disciplina.activeStudentsCount,
                              singular: 'explicador',
                              plural: 'explicadores',
                            ),
                            cycleLabel: disciplina.cicloEstudosLabel,
                            areaLabel:
                                disciplina.areaNome ?? selectedArea!.nome,
                            imageAsset: visuals.imageAsset,
                            iconData: visuals.icon,
                            dotColor: visuals.dotColor,
                            onTap: () => Navigator.of(context).pushNamed(
                              Routes.explicadores,
                              arguments: ExplicadoresScreenArgs(
                                initialQuery: disciplina.nome,
                              ),
                            ),
                          );
                        },
                      ),
                      if (disciplina != disciplinas.last)
                        const SizedBox(height: 16),
                    ]
                  else
                    for (final area in areas) ...[
                      Builder(
                        builder: (context) {
                          final visuals = getAreaVisuals(area.nome);
                          return DisciplinasMobileAreaCard(
                            title: area.nome.toUpperCase(),
                            subtitle: _formatCount(
                              area.professorCount,
                              singular: 'explicador',
                              plural: 'explicadores',
                            ),
                            imageAsset: visuals.imageAsset,
                            iconData: visuals.icon,
                            dotColor: visuals.dotColor,
                            selected: selectedArea?.idArea == area.idArea,
                            onTap: () => onAreaSelected(area.idArea),
                          );
                        },
                      ),
                      if (area != areas.last) const SizedBox(height: 16),
                    ],
                ],
              ),
          ],
          const SizedBox(height: 32),
          const DisciplinasMobileRatingsBanner(),
          const SizedBox(height: 24),
          const DisciplinasMobileCtaSection(),
        ],
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Disciplinas',
          style: TextStyle(
            fontSize: 36,
            height: 1.02,
            fontWeight: FontWeight.w700,
            color: DisciplinasMobileLayout.textPrimary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Escolhe uma área ou disciplina específica para encontrar o explicador perfeito para ti.',
          style: TextStyle(
            fontSize: 16,
            height: 1.45,
            color: DisciplinasMobileLayout.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AreaChipsRow extends StatelessWidget {
  const _AreaChipsRow({
    required this.areas,
    required this.selectedAreaId,
    required this.onAreaSelected,
  });

  final List<AreaDto> areas;
  final String? selectedAreaId;
  final ValueChanged<String> onAreaSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final area in areas) ...[
            _AreaChip(
              label: area.nome,
              selected: selectedAreaId == area.idArea,
              onTap: () => onAreaSelected(area.idArea),
            ),
            if (area != areas.last) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: DisciplinasMobileLayout.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: DisciplinasMobileLayout.textMuted,
          ),
        ),
      ],
    );
  }
}

class _SelectedAreaHeader extends StatelessWidget {
  const _SelectedAreaHeader({
    required this.area,
    required this.disciplinaCount,
    required this.onBackTap,
  });

  final AreaDto area;
  final int disciplinaCount;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    final visuals = getAreaVisuals(area.nome);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: DisciplinasMobileLayout.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DisciplinasMobileLayout.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onBackTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: DisciplinasMobileLayout.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 18,
                    color: DisciplinasMobileLayout.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Voltar às áreas',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DisciplinasMobileLayout.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: visuals.dotColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: visuals.imageAsset != null
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          visuals.imageAsset!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Icon(visuals.icon, color: visuals.dotColor, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.nome.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        height: 1.06,
                        fontWeight: FontWeight.w700,
                        color: DisciplinasMobileLayout.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      disciplinaCount == 1
                          ? '1 disciplina disponível'
                          : '$disciplinaCount disciplinas disponíveis',
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: DisciplinasMobileLayout.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: visuals.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Escolhe uma disciplina para encontrares explicadores com boa leitura e navegação no telemóvel.',
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              color: DisciplinasMobileLayout.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DisciplinasMobileLayout.chipRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF3E8) : Colors.white,
          borderRadius: BorderRadius.circular(
            DisciplinasMobileLayout.chipRadius,
          ),
          border: Border.all(
            color: selected
                ? DisciplinasMobileLayout.accentOrange
                : DisciplinasMobileLayout.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected
                ? DisciplinasMobileLayout.accentOrange
                : DisciplinasMobileLayout.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DisciplinasMobileLayout.border),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 15,
          height: 1.4,
          color: DisciplinasMobileLayout.textMuted,
        ),
      ),
    );
  }
}
