import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/features/aluno/areas_aluno/constants/areas_aluno_constants.dart';
import 'package:flutter/material.dart';

class DisciplinaCard extends StatelessWidget {
  const DisciplinaCard({
    super.key,
    required this.disciplina,
    required this.areaName,
    required this.imageAsset,
    required this.onViewDetails,
    required this.onMarkLesson,
    required this.onRemove,
    required this.scheduledLessons,
    required this.pendingTasks,
    required this.nextLessonText,
    required this.nextLessonColor,
  });

  final DisciplinaDto disciplina;
  final String areaName;
  final String imageAsset;
  final VoidCallback onViewDetails;
  final VoidCallback onMarkLesson;
  final VoidCallback onRemove;

  final int scheduledLessons;
  final int pendingTasks;
  final String nextLessonText;
  final Color nextLessonColor;

  @override
  Widget build(BuildContext context) {
    final title = disciplina.nome.trim().isEmpty ? 'Disciplina' : disciplina.nome.trim();

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(34.574, 34.574, 34.574, 16.596),
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
                      imageAsset,
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontSize: 27.66,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF101828),
                        height: 38.723 / 27.66,
                      ),
                    ),
                    const SizedBox(height: 16.596),
                    _StatRow(
                      label: 'Aulas marcadas:',
                      value: '$scheduledLessons',
                      valueColor: const Color(0xFF101828),
                    ),
                    const SizedBox(height: 11.064),
                    _StatRow(
                      label: 'Tarefas pendentes:',
                      value: '$pendingTasks',
                      valueColor: pendingTasks > 0
                          ? AreasAlunoConstants.orangeStart
                          : const Color(0xFF101828),
                    ),
                    const SizedBox(height: 11.064),
                    _StatRow(
                      label: 'Próxima aula:',
                      value: nextLessonText,
                      valueColor: nextLessonColor,
                    ),
                    const SizedBox(height: 2.383),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 80.277,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AreasAlunoConstants.orangeGradient,
                                borderRadius: BorderRadius.circular(19.362),
                              ),
                              child: TextButton(
                                onPressed: onViewDetails,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(19.362),
                                  ),
                                  alignment: Alignment.center,
                                ),
                                child: const Center(
                                  child: Text(
                                    'Ver\nDetalhes',
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
                          height: 85.277,
                          child: OutlinedButton(
                            onPressed: onMarkLesson,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 1.383,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19.362),
                              ),
                              foregroundColor: const Color(0xFF364153),
                              alignment: Alignment.center,
                            ),
                            child: const Center(
                              child: Text(
                                'Marcar\nAula',
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
                onTap: onRemove,
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    size: 22,
                    color: Color(0xFF364153),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            style: const TextStyle(
              fontSize: 19.362,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4A5565),
              height: 27.66 / 19.362,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 19.362,
              fontWeight: FontWeight.w500,
              color: valueColor,
              height: 27.66 / 19.362,
            ),
          ),
        ),
      ],
    );
  }
}
