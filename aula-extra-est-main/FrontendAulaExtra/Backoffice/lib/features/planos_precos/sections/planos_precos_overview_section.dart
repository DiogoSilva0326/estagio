import 'package:flutter/material.dart';

import '../models/plano_item.dart';
import 'planos_precos_commission_section.dart';
import 'planos_precos_grid_section.dart';
import 'planos_precos_header_section.dart';

class PlanosPrecosOverviewSection extends StatelessWidget {
  const PlanosPrecosOverviewSection({
    required this.items,
    required this.commissionController,
    required this.onCreatePlan,
    required this.onSaveCommission,
    required this.onEditPlan,
    super.key,
  });

  final List<PlanoItem> items;
  final TextEditingController commissionController;
  final VoidCallback onCreatePlan;
  final VoidCallback onSaveCommission;
  final ValueChanged<int> onEditPlan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlanosPrecosHeaderSection(onCreatePlan: onCreatePlan),
        const SizedBox(height: 37.273),
        PlanosPrecosCommissionSection(
          controller: commissionController,
          onSave: onSaveCommission,
        ),
        const SizedBox(height: 47.757),
        PlanosPrecosGridSection(items: items, onEditPlan: onEditPlan),
      ],
    );
  }
}
