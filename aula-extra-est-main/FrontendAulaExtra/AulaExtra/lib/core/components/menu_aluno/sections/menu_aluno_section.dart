import 'package:aula_extra/core/components/menu_aluno/constants/menu_aluno_colors.dart';
import 'package:aula_extra/core/components/menu_aluno/constants/menu_aluno_items.dart';
import 'package:aula_extra/core/components/menu_aluno/widgets/menu_aluno_nav_item.dart';
import 'package:aula_extra/core/components/menu_aluno/widgets/menu_aluno_stat_row.dart';
import 'package:flutter/material.dart';

class MenuAlunoSection extends StatelessWidget {
  const MenuAlunoSection({
    super.key,
    this.selectedIndex,
    required this.notificationCount,
    required this.aulasEstaSemana,
    required this.tarefasPendentes,
    required this.proximaAulaEm,
    this.onItemTap,
  });

  final int? selectedIndex;
  final int notificationCount;

  final int aulasEstaSemana;
  final int tarefasPendentes;
  final String proximaAulaEm;

  final ValueChanged<int>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 308,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: MenuAlunoColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Menu do Estudante',
                style: TextStyle(
                  fontSize: 22,
                  height: 28 / 22,
                  fontWeight: FontWeight.w600,
                  color: MenuAlunoColors.textHeading,
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(MenuAlunoItems.all.length, (index) {
                final item = MenuAlunoItems.all[index];
                final badgeCount = item.hasBadge ? notificationCount : null;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MenuAlunoNavItem(
                    icon: item.icon,
                    label: item.label,
                    badgeCount: badgeCount,
                    selected: selectedIndex == index,
                    onTap: onItemTap == null ? null : () => onItemTap!(index),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: MenuAlunoColors.divider)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estatísticas',
                      style: TextStyle(
                        fontSize: 22,
                        height: 20 / 22,
                        fontWeight: FontWeight.w600,
                        color: MenuAlunoColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MenuAlunoStatRow(
                      label: 'Aulas esta semana:',
                      value: '$aulasEstaSemana',
                      valueColor: MenuAlunoColors.accentOrange,
                    ),
                    const SizedBox(height: 12),
                    MenuAlunoStatRow(
                      label: 'Tarefas pendentes:',
                      value: '$tarefasPendentes',
                      valueColor: MenuAlunoColors.accentOrange,
                    ),
                    const SizedBox(height: 12),
                    MenuAlunoStatRow(
                      label: 'Próxima aula em:',
                      value: proximaAulaEm,
                      valueColor: MenuAlunoColors.accentGreen,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
