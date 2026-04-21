import 'package:aula_extra/features/aluno/avaliacoes/constants/avaliacoes_constants.dart';
import 'package:flutter/material.dart';

class AvaliacoesMobileModeTabs extends StatelessWidget {
  const AvaliacoesMobileModeTabs({
    super.key,
    required this.isLessonsSelected,
    required this.onLessonsTap,
    required this.onProfessorTap,
  });

  final bool isLessonsSelected;
  final VoidCallback onLessonsTap;
  final VoidCallback onProfessorTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AvaliacoesConstants.mobileSoftSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AvaliacoesConstants.mobileBorderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: 'Por aula',
              selected: isLessonsSelected,
              onTap: onLessonsTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ModeChip(
              label: 'Por professor',
              selected: !isLessonsSelected,
              onTap: onProfessorTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected ? AvaliacoesConstants.mobileShadow : null,
          ),
          child: Text(
            label,
            style: AvaliacoesConstants.mobileTabStyle.copyWith(
              color: selected
                  ? AvaliacoesConstants.mobileTextColor
                  : AvaliacoesConstants.mobileMutedColor,
            ),
          ),
        ),
      ),
    );
  }
}
