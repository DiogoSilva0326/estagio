import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/features/disciplinas/utils/area_visuals.dart';
import 'package:aula_extra/features/disciplinas/widgets/subject_card.dart';
import 'package:aula_extra/features/explicadores/pages/explicadores_screen.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class PopularAreasSection extends StatelessWidget {
  const PopularAreasSection({
    super.key,
    required this.areas,
    required this.disciplinas,
    required this.selectedArea,
    required this.onAreaSelected,
    required this.onClearArea,
  });

  final List<AreaDto> areas;
  final List<DisciplinaDto> disciplinas;
  final AreaDto? selectedArea;
  final ValueChanged<String> onAreaSelected;
  final VoidCallback onClearArea;

  String _formatProfessorCount(int count) {
    if (count == 1) return '1 explicador';
    return '$count explicadores';
  }

  @override
  Widget build(BuildContext context) {
    final showingDisciplinas = selectedArea != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              showingDisciplinas
                  ? 'Disciplinas em ${selectedArea!.nome}'
                  : 'Áreas Populares',
              style: const TextStyle(
                fontSize: 30.638,
                height: 1.333,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const Spacer(),
            if (showingDisciplinas)
              TextButton.icon(
                onPressed: onClearArea,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Voltar às áreas'),
              ),
          ],
        ),
        const SizedBox(height: 30.638),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axisAlignment: -1,
                child: child,
              ),
            );
          },
          child: SizedBox(
            key: ValueKey<String>(selectedArea?.idArea ?? 'all-areas'),
            width: 949.787,
            child: showingDisciplinas && disciplinas.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(30.638),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.532),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Text(
                      'Não encontrámos disciplinas associadas a esta área.',
                      style: TextStyle(
                        fontSize: 20.426,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4A5565),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 30.638,
                    runSpacing: 30.638,
                    children: showingDisciplinas
                        ? [
                            for (final disciplina in disciplinas)
                              Builder(
                                builder: (context) {
                                  final visuals = getAreaVisuals(
                                    disciplina.areaNome ?? selectedArea!.nome,
                                  );
                                  return SubjectCard(
                                    title: disciplina.nome.toUpperCase(),
                                    subtitle: _formatProfessorCount(disciplina.activeStudentsCount),
                                    imageAsset: visuals.imageAsset,
                                    iconData: visuals.icon,
                                    dotColor: visuals.dotColor,
                                    onTap: () => Navigator.of(context).pushNamed(
                                      Routes.explicadores,
                                      arguments: ExplicadoresScreenArgs(initialQuery: disciplina.nome),
                                    ),
                                  );
                                },
                              ),
                          ]
                        : [
                            for (final area in areas)
                              Builder(
                                builder: (context) {
                                  final visuals = getAreaVisuals(area.nome);
                                  return SubjectCard(
                                    title: area.nome.toUpperCase(),
                                    subtitle: _formatProfessorCount(area.professorCount),
                                    imageAsset: visuals.imageAsset,
                                    iconData: visuals.icon,
                                    dotColor: visuals.dotColor,
                                    selected: selectedArea?.idArea == area.idArea,
                                    onTap: () => onAreaSelected(area.idArea),
                                  );
                                },
                              ),
                          ],
                  ),
          ),
        ),
      ],
    );
  }
}
