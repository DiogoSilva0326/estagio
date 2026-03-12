import 'package:aula_extra/features/aluno/areas_aluno/models/area_overview.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/area_details_dialog.dart';
import 'package:aula_extra/features/aluno/areas_aluno/widgets/dialogs/area_mark_lesson_dialog.dart';
import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:flutter/material.dart';

class AreaCard extends StatelessWidget {
  const AreaCard({
    super.key,
    required this.area,
    this.onRemoveArea,
  });

  final AreaOverview area;
  final VoidCallback? onRemoveArea;

  static const _chipBg = Color(0xFFF3F4F6);
  static const _chipText = Color(0xFF4A5565);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(34.574, 34.574, 34.574, 1.383),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1.383),
            borderRadius: BorderRadius.circular(22.128),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                offset: Offset(0, 1.383),
                blurRadius: 4.149,
              ),
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.10),
                offset: Offset(0, 1.383),
                blurRadius: 2.766,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22.128),
            child: SizedBox(
              width: 88.511,
              height: 88.511,
              child: Center(
                child: Image.asset(
                  area.imageAsset,
                  width: 81.702,
                  height: 81.702,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 22.128),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  area.name,
                  style: const TextStyle(
                    fontSize: 27.66,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF101828),
                    height: 38.723 / 27.66,
                  ),
                ),
                const SizedBox(height: 16.596),
                const Text(
                  'Disciplinas selecionadas:',
                  style: TextStyle(
                    fontSize: 19.362,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4A5565),
                    height: 27.66 / 19.362,
                  ),
                ),
                const SizedBox(height: 11.064),
                if (area.selectedDisciplinaNames.isEmpty)
                  const Text(
                    'Nenhuma disciplina selecionada',
                    style: TextStyle(
                      fontSize: 19.362,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101828),
                      height: 27.66 / 19.362,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final name in area.selectedDisciplinaNames)
                        Chip(
                          label: Text(
                            name,
                            style: const TextStyle(
                              color: _chipText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: _chipBg,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                    ],
                  ),
                const SizedBox(height: 16.596),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 91.277,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AreasAlunoConstants.orangeGradient,
                            borderRadius: BorderRadius.circular(19.362),
                          ),
                          child: TextButton(
                            onPressed: () => showAreaDetailsDialog(
                              context,
                              area: area,
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(19.362)),
                              alignment: Alignment.center,
                            ),
                            child: const Center(
                              child: Text(
                                'Ver Detalhes',
                                style: TextStyle(
                                  fontSize: 22.128,
                                  fontWeight: FontWeight.w400,
                                  height: 33.191 / 22.128,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11.064),
                    SizedBox(
                      width: 154.386,
                      height: 91.277,
                      child: OutlinedButton(
                        onPressed: () => showAreaMarkLessonDialog(
                          context,
                          area: area,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFFE5E7EB), width: 1.383),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19.362)),
                          foregroundColor: const Color(0xFF364153),
                          alignment: Alignment.center,
                        ),
                        child: const Center(
                          child: Text(
                            'Marcar Aula',
                            style: TextStyle(
                              fontSize: 22.128,
                              fontWeight: FontWeight.w400,
                              height: 33.191 / 22.128,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
          ),
        ),
        if (onRemoveArea != null)
          Positioned(
            top: 10,
            right: 10,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: onRemoveArea,
                  child: const Center(
                    child: Icon(Icons.delete_outline, size: 22, color: Color(0xFF364153)),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
