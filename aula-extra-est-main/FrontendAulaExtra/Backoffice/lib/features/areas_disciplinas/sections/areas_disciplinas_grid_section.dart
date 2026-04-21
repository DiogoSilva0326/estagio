import 'package:flutter/material.dart';

import '../models/area_disciplinas_item.dart';
import '../widgets/area_disciplinas_card.dart';

class AreasDisciplinasGridSection extends StatelessWidget {
  const AreasDisciplinasGridSection({
    super.key,
    required this.items,
    this.onEditArea,
    this.onAddDisciplina,
  });

  final List<AreaDisciplinasItem> items;
  final ValueChanged<int>? onEditArea;
  final ValueChanged<int>? onAddDisciplina;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 880
            ? (constraints.maxWidth - 27.955) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 27.955,
          runSpacing: 27.955,
          children: [
            for (var index = 0; index < items.length; index++)
              SizedBox(
                width: cardWidth,
                child: AreaDisciplinasCard(
                  item: items[index],
                  onEdit: onEditArea == null ? null : () => onEditArea!(index),
                  onAddDisciplina: onAddDisciplina == null
                      ? null
                      : () => onAddDisciplina!(index),
                ),
              ),
          ],
        );
      },
    );
  }
}
