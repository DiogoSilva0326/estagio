import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_colors.dart';
import 'package:flutter/material.dart';

class MenuProfessorNavItem extends StatelessWidget {
  const MenuProfessorNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.badgeCount,
    this.selected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int? badgeCount;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showBadge = (badgeCount ?? 0) > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.773),
      child: Container(
        height: 59.091,
        padding: const EdgeInsets.symmetric(horizontal: 19.697),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.773),
          color: selected ? MenuProfessorColors.navSelectedBackground : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.621,
              color: selected ? MenuProfessorColors.accentOrange : MenuProfessorColors.textNav,
            ),
            const SizedBox(width: 14.773),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 19.697,
                  height: 29.545 / 19.697,
                  fontWeight: FontWeight.w500,
                  color: selected ? MenuProfessorColors.accentOrange : MenuProfessorColors.textNav,
                ),
              ),
            ),
            if (showBadge) ...[
              Container(
                height: 24.621,
                width: 28.18,
                decoration: BoxDecoration(
                  color: MenuProfessorColors.badgeRed,
                  borderRadius: BorderRadius.circular(20653750),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${badgeCount ?? 0}',
                  style: const TextStyle(
                    fontSize: 14.773,
                    height: 19.697 / 14.773,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
