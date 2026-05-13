import 'package:aula_extra/core/components/menu_professor/constants/menu_professor_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';

class MenuProfessorNavItem extends StatelessWidget {
  const MenuProfessorNavItem({
    super.key,
    required this.icon,
    required this.label,
    this.badgeCount,
    this.selected = false,
    this.activeColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int? badgeCount;
  final bool selected;
  final Color? activeColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final showBadge = (badgeCount ?? 0) > 0;
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    final primaryColor = activeColor ?? config.primaryColor;

    final bgColor = selected 
        ? primaryColor.withOpacity(0.12) 
        : Colors.transparent;

    final contentColor = selected 
        ? primaryColor 
        : MenuProfessorColors.textNav;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.773),
      child: Container(
        height: 59.091,
        padding: const EdgeInsets.symmetric(horizontal: 19.697),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.773),
          color: bgColor,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.621,
              color: contentColor,
            ),
            const SizedBox(width: 14.773),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 19.697,
                  height: 29.545 / 19.697,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500, 
                  color: contentColor,
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