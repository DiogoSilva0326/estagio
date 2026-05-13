import 'package:flutter/material.dart';

import '../models/reclamacao_item.dart';
import 'reclamacoes_header_section.dart';
import 'reclamacoes_table_section.dart';

class ReclamacoesOverviewSection extends StatelessWidget {
  const ReclamacoesOverviewSection({
    required this.items,
    required this.selectedSource,
    required this.searchController,
    required this.types,
    required this.selectedType,
    required this.isLoading,
    required this.warningMessage,
    required this.onDataChanged,
    required this.onSourceChanged,
    required this.onSearchChanged,
    required this.onTypeChanged,
    super.key,
  });

  final List<ReclamacaoItem> items;
  final ReclamacaoSource selectedSource;
  final TextEditingController searchController;
  final List<String> types;
  final String? selectedType;
  final bool isLoading;
  final String? warningMessage;
  final Future<void> Function() onDataChanged;
  final ValueChanged<ReclamacaoSource> onSourceChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReclamacoesHeaderSection(selectedSource: selectedSource),
        const SizedBox(height: 37.273),
        ReclamacoesTableSection(
          items: items,
          selectedSource: selectedSource,
          searchController: searchController,
          types: types,
          selectedType: selectedType,
          isLoading: isLoading,
          warningMessage: warningMessage,
          onDataChanged: onDataChanged,
          onSourceChanged: onSourceChanged,
          onSearchChanged: onSearchChanged,
          onTypeChanged: onTypeChanged,
        ),
      ],
    );
  }
}
