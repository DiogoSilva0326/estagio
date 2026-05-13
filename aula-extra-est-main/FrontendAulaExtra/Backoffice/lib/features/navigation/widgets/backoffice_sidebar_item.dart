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
    const itemHeight = 51.25;
    const itemHorizontalPadding = 16.0;
    const itemVerticalPadding = 12.0;
    const iconSize = 20.0;
    const iconSpacing = 14.0;
    const borderRadiusValue = 16.0;

    final textStyle = TextStyle(
      color: isSelected ? Colors.white : AppColors.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w700,
      height: 20 / 14,
      letterSpacing: -0.15,
    );

    final borderRadius = BorderRadius.circular(borderRadiusValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Ink(
            height: itemHeight,
            decoration: ShapeDecoration(
              color: isSelected ? null : Colors.transparent,
              gradient: isSelected ? _selectedGradient : null,
              shape: RoundedRectangleBorder(borderRadius: borderRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: itemHorizontalPadding,
              vertical: itemVerticalPadding,
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: iconSize,
                  color: isSelected ? Colors.white : AppColors.textMuted,
                ),
                const SizedBox(width: iconSpacing),
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
