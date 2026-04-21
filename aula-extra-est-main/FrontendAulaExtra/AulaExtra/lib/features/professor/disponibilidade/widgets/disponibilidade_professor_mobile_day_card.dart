import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_colors.dart';
import 'package:aula_extra/features/professor/disponibilidade/constants/disponibilidade_professor_layout.dart';
import 'package:flutter/material.dart';

class DisponibilidadeProfessorMobileDayCard extends StatelessWidget {
  const DisponibilidadeProfessorMobileDayCard({
    super.key,
    required this.dayLabel,
    this.dateLabel = '',
    required this.slots,
    required this.isSelected,
    required this.onToggleSlot,
    required this.onClearDay,
  });

  final String dayLabel;
  final String dateLabel;
  final List<String> slots;
  final bool Function(int hourIndex) isSelected;
  final ValueChanged<int> onToggleSlot;
  final VoidCallback onClearDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        DisponibilidadeProfessorLayout.mobileDayCardPadding,
      ),
      decoration: BoxDecoration(
        color: DisponibilidadeProfessorColors.mobileSurface,
        borderRadius: BorderRadius.circular(
          DisponibilidadeProfessorLayout.mobileCardRadius,
        ),
        border: Border.all(color: DisponibilidadeProfessorColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(16, 24, 40, 0.06),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: DisponibilidadeProfessorColors.mobileDayHeaderBackground,
              borderRadius: BorderRadius.circular(
                DisponibilidadeProfessorLayout.mobileDayHeaderRadius,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayLabel,
                        style: const TextStyle(
                          color: DisponibilidadeProfessorColors.title,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          height: 24 / 18,
                        ),
                      ),
                      if (dateLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            color: DisponibilidadeProfessorColors.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 18 / 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  height:
                      DisponibilidadeProfessorLayout.mobileClearButtonHeight,
                  child: OutlinedButton.icon(
                    onPressed: onClearDay,
                    icon: const Icon(Icons.clear_all_rounded, size: 14),
                    label: const Text('Limpar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      foregroundColor:
                          DisponibilidadeProfessorColors.clearDayAccent,
                      backgroundColor:
                          DisponibilidadeProfessorColors.clearDayBackground,
                      side: const BorderSide(color: Color(0xFFFED7AA)),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: slots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              mainAxisExtent: 40,
            ),
            itemBuilder: (context, index) {
              final selected = isSelected(index);

              return InkWell(
                onTap: () => onToggleSlot(index),
                borderRadius: BorderRadius.circular(
                  DisponibilidadeProfessorLayout.mobileSlotRadius,
                ),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? DisponibilidadeProfessorColors.mobileAvailableFill
                        : DisponibilidadeProfessorColors.mobileUnavailableFill,
                    borderRadius: BorderRadius.circular(
                      DisponibilidadeProfessorLayout.mobileSlotRadius,
                    ),
                    border: Border.all(
                      color: selected
                          ? DisponibilidadeProfessorColors.availableBorder
                          : DisponibilidadeProfessorColors.unavailableBorder,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    slots[index],
                    style: TextStyle(
                      color: selected
                          ? DisponibilidadeProfessorColors.availableBorder
                          : DisponibilidadeProfessorColors.text,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      height: 18 / 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
