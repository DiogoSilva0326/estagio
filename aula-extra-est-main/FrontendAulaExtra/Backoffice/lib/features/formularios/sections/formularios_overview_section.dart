import 'package:flutter/material.dart';

import '../models/formulario_item.dart';
import 'formularios_header_section.dart';
import 'formularios_table_section.dart';

class FormulariosOverviewSection extends StatelessWidget {
  const FormulariosOverviewSection({
    required this.items,
    required this.searchController,
    required this.onSearchChanged,
    required this.onDataChanged,
    required this.isLoading,
    required this.warningMessage,
    super.key,
  });

  final List<FormularioItem> items;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final Future<void> Function() onDataChanged;
  final bool isLoading;
  final String? warningMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormulariosHeaderSection(),
        const SizedBox(height: 37.273),
        FormulariosTableSection(
          items: items,
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          onDataChanged: onDataChanged,
          isLoading: isLoading,
          warningMessage: warningMessage,
        ),
      ],
    );
  }
}
