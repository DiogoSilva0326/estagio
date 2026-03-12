import 'package:aula_extra/core/components/menu_aluno/constants/menu_aluno_colors.dart';
import 'package:flutter/material.dart';

class MenuAlunoNavItem extends StatelessWidget {
  const MenuAlunoNavItem({
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

  static const _selectedStart = Color(0xFFFF6B00);
  static const _selectedEnd = Color(0xFFFF9966);

  @override
  Widget build(BuildContext context) {
    final showBadge = (badgeCount ?? 0) > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_selectedStart, _selectedEnd],
                )
              : null,
          color: selected ? null : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? Colors.white : MenuAlunoColors.textNav),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 19,
                  height: 24 / 19,
                  fontWeight: FontWeight.w400,
                  color: selected ? Colors.white : MenuAlunoColors.textNav,
                ),
              ),
            ),
            if (showBadge) ...[
              Container(
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  color: MenuAlunoColors.badgeRed,
                  borderRadius: BorderRadius.circular(9999),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${badgeCount ?? 0}',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
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
