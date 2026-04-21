import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/backoffice_nav_section.dart';
import 'backoffice_sidebar_item.dart';

class BackofficeSidebarSection extends StatelessWidget {
  const BackofficeSidebarSection({
    required this.section,
    required this.currentRoute,
    required this.onItemTap,
    super.key,
  });

  final BackofficeNavSection section;
  final String currentRoute;
  final ValueChanged<String> onItemTap;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.textMuted,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(section.title.toUpperCase(), style: labelStyle),
          ),
        ],
        for (final item in section.items)
          BackofficeSidebarItem(
            item: item,
            isSelected: currentRoute == item.route,
            onTap: () => onItemTap(item.route),
          ),
      ],
    );
  }
}
