import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_colors.dart';
import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_items.dart';
import 'package:aula_extra/core/components/menu_professor/widgets/menu_professor_nav_item.dart';
import 'package:aula_extra/core/components/menu_professor/widgets/menu_professor_stat_row.dart';
import 'package:flutter/material.dart';

class MenuProfessorSection extends StatelessWidget {
  const MenuProfessorSection({
    super.key,
    this.selectedIndex,
    required this.notificationCount,
    required this.aulasEstaSemana,
    required this.ganhosPendentes,
    required this.alunosAtivos,
    this.onItemTap,
  });

  final int? selectedIndex;
  final int notificationCount;

  final int aulasEstaSemana;
  final String ganhosPendentes;
  final int alunosAtivos;

  final ValueChanged<int>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 307.765,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MenuProfessorColors.background,
          borderRadius: BorderRadius.circular(20),
          border: const Border(
            right: BorderSide(color: MenuProfessorColors.divider, width: 1.231),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(19.697, 19.697, 39.394, 19.697),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 34.47,
                  child: Text(
                    'Menu do Explicador',
                    style: TextStyle(
                      fontSize: 22.159,
                      height: 34.47 / 22.159,
                      fontWeight: FontWeight.w600,
                      color: MenuProfessorColors.textHeading,
                    ),
                  ),
                ),
                const SizedBox(height: 19.697),
                ...List.generate(MenuProfessorItems.all.length, (index) {
                  final item = MenuProfessorItems.all[index];
                  final badgeCount = item.hasBadge ? notificationCount : null;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == MenuProfessorItems.all.length - 1 ? 0 : 4.924,
                    ),
                    child: MenuProfessorNavItem(
                      icon: item.icon,
                      label: item.label,
                      badgeCount: badgeCount,
                      selected: selectedIndex == index,
                      onTap: onItemTap == null ? null : () => onItemTap!(index),
                    ),
                  );
                }),
                const SizedBox(height: 19.697),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(19.697, 19.697, 19.697, 19.697),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19.697),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD4)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 33.239,
                        child: Text(
                          'Estatísticas',
                          style: TextStyle(
                            fontSize: 22.159,
                            height: 33.239 / 22.159,
                            fontWeight: FontWeight.w600,
                            color: MenuProfessorColors.textHeading,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14.773),
                      MenuProfessorStatRow(
                        label: 'Aulas esta semana:',
                        value: '$aulasEstaSemana',
                        valueColor: MenuProfessorColors.accentOrange,
                      ),
                      const SizedBox(height: 9.848),
                      MenuProfessorStatRow(
                        label: 'Ganhos pendentes:',
                        value: ganhosPendentes,
                        valueColor: MenuProfessorColors.accentGreen,
                      ),
                      const SizedBox(height: 9.848),
                      MenuProfessorStatRow(
                        label: 'Alunos ativos:',
                        value: '$alunosAtivos',
                        valueColor: MenuProfessorColors.accentBlue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
