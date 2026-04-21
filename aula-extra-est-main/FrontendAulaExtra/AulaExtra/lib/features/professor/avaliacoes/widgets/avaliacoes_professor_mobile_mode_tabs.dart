import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_layout.dart';
import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_tabs.dart';
import 'package:flutter/material.dart';

class AvaliacoesProfessorMobileModeTabs extends StatelessWidget {
  const AvaliacoesProfessorMobileModeTabs({
    super.key,
    required this.selectedTab,
    required this.onChanged,
  });

  final AvaliacoesProfessorTab selectedTab;
  final ValueChanged<AvaliacoesProfessorTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AvaliacoesProfessorColors.cardBorder),
      ),
      child: Row(
        children: AvaliacoesProfessorTab.values
            .map((tab) {
              final selected = selectedTab == tab;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: tab == AvaliacoesProfessorTab.professor ? 8 : 0,
                  ),
                  child: Material(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => onChanged(tab),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: AvaliacoesProfessorLayout.mobileTabHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: selected
                              ? const [
                                  BoxShadow(
                                    color: Color(0x14000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          tab.label,
                          style: TextStyle(
                            color: selected
                                ? AvaliacoesProfessorColors.title
                                : AvaliacoesProfessorColors.muted,
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            height: 20 / 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
