import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/backoffice_nav_item.dart';

class BackofficeSidebarItem extends StatelessWidget {
  const BackofficeSidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  static const LinearGradient _selectedGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
  );

  final BackofficeNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: isSelected ? Colors.white : AppColors.textSecondary,
      fontSize: isSelected ? 16.31 : 14,
      fontWeight: FontWeight.w700,
      height: isSelected ? 1.43 : 20 / 14,
      letterSpacing: isSelected ? -0.18 : -0.15,
    );

    final borderRadius = BorderRadius.circular(isSelected ? 18.64 : 16);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Ink(
            height: 51.25,
            decoration: ShapeDecoration(
              color: isSelected ? null : Colors.transparent,
              gradient: isSelected ? _selectedGradient : null,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 18.64 : 16,
              vertical: isSelected ? 13.98 : 12,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: isSelected ? 23.30 : 20,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
                SizedBox(width: isSelected ? 16.30 : 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
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
