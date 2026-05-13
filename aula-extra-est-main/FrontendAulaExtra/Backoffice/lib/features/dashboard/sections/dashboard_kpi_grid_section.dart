import 'package:flutter/material.dart';

import '../models/dashboard_kpi_item.dart';
import '../widgets/dashboard_metric_item.dart';

class DashboardKpiGridSection extends StatelessWidget {
  const DashboardKpiGridSection({required this.items, super.key});

  final List<DashboardKpiItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 860
            ? 2
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        const spacing = 28.0;
        final itemWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: DashboardMetricItem(item: item),
              ),
          ],
        );
      },
    );
  }
}
