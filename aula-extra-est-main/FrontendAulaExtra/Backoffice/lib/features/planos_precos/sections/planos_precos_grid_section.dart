import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/plano_item.dart';
import '../widgets/plano_card.dart';

class PlanosPrecosGridSection extends StatelessWidget {
  static const double _spacing = 12.263;
  static const double _runSpacing = 18.637;
  static const double _minCardWidth = 280;

  const PlanosPrecosGridSection({
    required this.items,
    required this.onEditPlan,
    super.key,
  });

  final List<PlanoItem> items;
  final ValueChanged<int> onEditPlan;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _resolveColumns(constraints.maxWidth, items.length);
        final totalSpacing = _spacing * (columns - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: _spacing,
          runSpacing: _runSpacing,
          children: [
            for (var index = 0; index < items.length; index++)
              SizedBox(
                width: itemWidth,
                child: PlanoCard(
                  item: items[index],
                  onEdit: () => onEditPlan(index),
                ),
              ),
          ],
        );
      },
    );
  }

  int _resolveColumns(double maxWidth, int itemCount) {
    final calculatedColumns =
        ((maxWidth + _spacing) / (_minCardWidth + _spacing)).floor();

    return math.max(1, math.min(3, math.min(itemCount, calculatedColumns)));
  }
}
