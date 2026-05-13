import 'package:flutter/material.dart';

import '../models/area_disciplinas_item.dart';
import 'areas_disciplinas_grid_section.dart';
import 'areas_disciplinas_header_section.dart';

class AreasDisciplinasOverviewSection extends StatelessWidget {
  const AreasDisciplinasOverviewSection({
    super.key,
    required this.items,
    this.onAddArea,
    this.onEditArea,
    this.onAddDisciplina,
  });

  final List<AreaDisciplinasItem> items;
  final VoidCallback? onAddArea;
  final ValueChanged<AreaDisciplinasItem>? onEditArea;
  final ValueChanged<AreaDisciplinasItem>? onAddDisciplina;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AreasDisciplinasHeaderSection(onAddArea: onAddArea),
        const SizedBox(height: 37.273),
        AreasDisciplinasGridSection(
          items: items,
          onEditArea: onEditArea,
          onAddDisciplina: onAddDisciplina,
        ),
      ],
    );
  }
}
