import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/faq_item.dart';
import '../widgets/faqs_category_filter_field.dart';
import '../widgets/faqs_search_field.dart';

class FaqsTableSection extends StatelessWidget {
  const FaqsTableSection({
    required this.items,
    required this.categories,
    required this.searchController,
    required this.selectedCategory,
    required this.isLoading,
    required this.warningMessage,
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
  final ValueChanged<FaqItem> onEdit;
  final ValueChanged<FaqItem> onDelete;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: EdgeInsets.zero,
      borderRadius: 27.955,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(37.273, 23.296, 37.273, 22),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 860) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gestão',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 32.614,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.512,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FaqsSearchField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                      ),
                      const SizedBox(height: 12),
                      FaqsCategoryFilterField(
                        categories: categories,
                        selectedCategory: selectedCategory,
                        onChanged: onCategoryChanged,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Gestão',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 32.614,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.512,
                        ),
                      ),
                    ),
                    FaqsSearchField(
                      controller: searchController,
                      onChanged: onSearchChanged,
                    ),
                    const SizedBox(width: 12),
                    FaqsCategoryFilterField(
                      categories: categories,
                      selectedCategory: selectedCategory,
                      onChanged: onCategoryChanged,
                    ),
                  ],
                );
              },
            ),
          ),
          Container(height: 1.165, color: AppColors.borderSoft),
          Padding(
            padding: const EdgeInsets.fromLTRB(27.955, 18.637, 27.955, 27.955),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (warningMessage != null && warningMessage!.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      warningMessage!,
                      style: const TextStyle(
                        color: Color(0xFF9A3412),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Text(
                      'Sem FAQs para os filtros atuais.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15.143,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (var index = 0; index < items.length; index++) ...[
                        _FaqExpandableCard(
                          key: ValueKey(items[index].id),
                          item: items[index],
                          onEdit: () => onEdit(items[index]),
                          onDelete: () => onDelete(items[index]),
                        ),
                        if (index != items.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqExpandableCard extends StatefulWidget {
  const _FaqExpandableCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final FaqItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_FaqExpandableCard> createState() => _FaqExpandableCardState();
}

class _FaqExpandableCardState extends State<_FaqExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.16, color: Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(27.96),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 23.30,
            offset: Offset(0, 4.66),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 55.91,
                height: 55.91,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF9FAFB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.31),
                  ),
                ),
                child: const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF98A2B3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.question,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 20.97,
                        fontFamily: 'Helvetica Neue',
                        fontWeight: FontWeight.w700,
                        height: 1.56,
                        letterSpacing: -0.51,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 10,
                      children: [
                        _Badge(
                          label: item.categoryLabel.toUpperCase(),
                          textColor: const Color(0xFFFC9039),
                          backgroundColor: const Color(0x19FB7B02),
                          letterSpacing: 1.36,
                        ),
                        _Badge(
                          label: 'PUBLICADA',
                          textColor: const Color(0xFF4CAF50),
                          backgroundColor: const Color(0x264CAF50),
                          letterSpacing: 0.72,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined),
                color: const Color(0xFF98A2B3),
                tooltip: 'Editar FAQ',
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFE57373),
                tooltip: 'Eliminar FAQ',
              ),
              IconButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                icon: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                ),
                color: const Color(0xFF98A2B3),
                tooltip: _isExpanded ? 'Recolher FAQ' : 'Expandir FAQ',
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                item.answer,
                style: const TextStyle(
                  color: Color(0xFF495565),
                  fontSize: 20.42,
                  fontFamily: 'Helvetica Neue',
                  fontWeight: FontWeight.w400,
                  height: 1.50,
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.letterSpacing,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11.65, vertical: 4.66),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11.65),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12.81,
          fontFamily: 'Helvetica Neue',
          fontWeight: FontWeight.w700,
          height: 1.50,
          letterSpacing: letterSpacing,
        ),
      ),
    );
  }
}
