import 'package:flutter/material.dart';

import '../models/faq_item.dart';
import 'faqs_header_section.dart';
import 'faqs_table_section.dart';

class FaqsOverviewSection extends StatelessWidget {
  const FaqsOverviewSection({
    required this.items,
    required this.categories,
    required this.searchController,
    required this.selectedCategory,
    required this.isLoading,
    required this.warningMessage,
    required this.onCreate,
    required this.onCreateCategory,
    required this.onEdit,
    required this.onDelete,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    super.key,
  });

  final List<FaqItem> items;
  final List<FaqCategoryOption> categories;
  final TextEditingController searchController;
  final String? selectedCategory;
  final bool isLoading;
  final String? warningMessage;
  final VoidCallback onCreate;
  final VoidCallback onCreateCategory;
  final ValueChanged<FaqItem> onEdit;
  final ValueChanged<FaqItem> onDelete;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FaqsHeaderSection(
          onCreate: onCreate,
          onCreateCategory: onCreateCategory,
        ),
        const SizedBox(height: 37.273),
        FaqsTableSection(
          items: items,
          categories: categories,
          searchController: searchController,
          selectedCategory: selectedCategory,
          isLoading: isLoading,
          warningMessage: warningMessage,
          onEdit: onEdit,
          onDelete: onDelete,
          onSearchChanged: onSearchChanged,
          onCategoryChanged: onCategoryChanged,
        ),
      ],
    );
  }
}
