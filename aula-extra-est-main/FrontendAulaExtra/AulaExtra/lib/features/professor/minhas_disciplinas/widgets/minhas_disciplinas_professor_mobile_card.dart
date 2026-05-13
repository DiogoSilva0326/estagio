import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_layout.dart';
import 'package:flutter/material.dart';

class MinhasDisciplinasProfessorMobileCard extends StatelessWidget {
  const MinhasDisciplinasProfessorMobileCard({
    super.key,
    required this.disciplina,
    required this.color,
    required this.onEdit,
    required this.onDelete,
    required this.studentLabel,
    required this.activeColor,
  });

  final DisciplinaDto disciplina;
  final Color color; 
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String studentLabel;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final isOrange = activeColor == const Color(0xFFFC9039);

    final trimmedName = disciplina.nome.trim();
    final initial = trimmedName.isEmpty
        ? '?'
        : trimmedName.characters.first.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        MinhasDisciplinasProfessorLayout.mobileCardPadding,
      ),
      decoration: BoxDecoration(
        color: MinhasDisciplinasProfessorColors.mobileSurface,
        borderRadius: BorderRadius.circular(
          MinhasDisciplinasProfessorLayout.mobileCardRadius,
        ),
        border: Border.all(color: MinhasDisciplinasProfessorColors.cardBorder),
        boxShadow: MinhasDisciplinasProfessorColors.mobileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius:
                    MinhasDisciplinasProfessorLayout
                        .mobileDisciplinaAvatarSize /
                    2,
                backgroundColor: color, 
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
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
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 24 / 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 16 / 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            icon: Icons.groups_2_outlined,
            label: '${disciplina.activeStudentsCount} $studentLabel ativos', 
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.school_outlined,
            label: disciplina.cicloEstudosLabel,
          ),
          if ((disciplina.descricao ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              disciplina.descricao!.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MinhasDisciplinasProfessorColors.mobileMutedText,
                fontSize: 13,
                height: 18 / 13,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height:
                      MinhasDisciplinasProfessorLayout.mobileActionButtonHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isOrange ? null : activeColor,
                      gradient: isOrange ? const LinearGradient(
                        colors: [
                          MinhasDisciplinasProfessorColors.buttonGradientTop,
                          MinhasDisciplinasProfessorColors.buttonGradientBottom,
                        ],
                      ) : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onEdit,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 20 / 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width:
                    MinhasDisciplinasProfessorLayout.mobileActionButtonHeight,
                height:
                    MinhasDisciplinasProfessorLayout.mobileActionButtonHeight,
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(
                      color: MinhasDisciplinasProfessorColors.dangerBorder,
                    ),
                    foregroundColor:
                        MinhasDisciplinasProfessorColors.dangerIcon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: MinhasDisciplinasProfessorColors.mobileMutedText,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: MinhasDisciplinasProfessorColors.mobileMutedText,
              fontSize: 14,
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}