import 'dart:math' as math;

import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_layout.dart';
import 'package:flutter/material.dart';

class DisciplinaCard extends StatelessWidget {
  const DisciplinaCard({
    super.key,
    required this.disciplina,
    required this.color,
    required this.width,
    required this.onEdit,
    required this.onDelete,
  });

  final DisciplinaDto disciplina;
  final Color color;
  final double width;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final trimmedName = disciplina.nome.trim();
    final initial = trimmedName.isEmpty
        ? '?'
        : trimmedName.characters.first.toUpperCase();

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: math.min(width, MinhasDisciplinasProfessorLayout.cardWidth),
        maxWidth: width,
        minHeight: MinhasDisciplinasProfessorLayout.cardMinHeight,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(27.394, 27.394, 27.394, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            MinhasDisciplinasProfessorLayout.cardRadius,
          ),
          boxShadow: const [
            BoxShadow(
              color: MinhasDisciplinasProfessorColors.cardShadow,
              blurRadius: 3.424,
              offset: Offset(0, 1.141),
            ),
            BoxShadow(
              color: MinhasDisciplinasProfessorColors.cardShadow,
              blurRadius: 2.283,
              offset: Offset(0, 1.141),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 27.394,
                  backgroundColor: color,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.545,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 13.697),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disciplina.nome,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MinhasDisciplinasProfessorColors.title,
                          fontSize: 20.545,
                          height: 31.959 / 20.545,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13.7,
                          vertical: 5.71,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          disciplina.areaLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: 13.697,
                            height: 18.262 / 13.697,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.262),
            Row(
              children: [
                const Icon(
                  Icons.groups_2_outlined,
                  size: 18.262,
                  color: MinhasDisciplinasProfessorColors.subtitle,
                ),
                const SizedBox(width: 9.131),
                Text(
                  '${disciplina.activeStudentsCount} alunos',
                  style: const TextStyle(
                    color: MinhasDisciplinasProfessorColors.subtitle,
                    fontSize: 15.98,
                    height: 22.828 / 15.98,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9.131),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.category_outlined,
                    size: 18.262,
                    color: MinhasDisciplinasProfessorColors.subtitle,
                  ),
                ),
                const SizedBox(width: 9.131),
                Expanded(
                  child: Text(
                    disciplina.areaLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MinhasDisciplinasProfessorColors.subtitle,
                      fontSize: 15.98,
                      height: 22.828 / 15.98,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9.131),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.school_outlined,
                    size: 18.262,
                    color: MinhasDisciplinasProfessorColors.subtitle,
                  ),
                ),
                const SizedBox(width: 9.131),
                Expanded(
                  child: Text(
                    disciplina.cicloEstudosLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MinhasDisciplinasProfessorColors.subtitle,
                      fontSize: 15.98,
                      height: 22.828 / 15.98,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18.262),
            Container(
              padding: const EdgeInsets.only(top: 19.403),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF3F4F6), width: 1.141),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MinhasDisciplinasProfessorLayout.cardActionHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9.131),
                          gradient: const LinearGradient(
                            colors: [
                              MinhasDisciplinasProfessorColors
                                  .buttonGradientTop,
                              MinhasDisciplinasProfessorColors
                                  .buttonGradientBottom,
                            ],
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9.131),
                            onTap: onEdit,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit_outlined,
                                  size: 18.262,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 9.131),
                                Text(
                                  'Editar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15.98,
                                    height: 22.828 / 15.98,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9.131),
                  SizedBox(
                    width:
                        MinhasDisciplinasProfessorLayout.cardDeleteButtonWidth,
                    height: MinhasDisciplinasProfessorLayout.cardActionHeight,
                    child: OutlinedButton(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: MinhasDisciplinasProfessorColors.dangerBorder,
                          width: 1.141,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.131),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18.262,
                        color: MinhasDisciplinasProfessorColors.dangerIcon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
