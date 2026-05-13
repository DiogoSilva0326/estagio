import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../models/faq_item.dart';
import '../sections/faqs_overview_section.dart';
import '../services/backoffice_faqs_service.dart';
import '../widgets/faq_category_dialog.dart';
import '../widgets/faq_dialog.dart';

class FaqsPage extends StatefulWidget {
  const FaqsPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<FaqsPage> createState() => _FaqsPageState();
}

class _FaqsPageState extends State<FaqsPage> {
  final BackofficeFaqsService _service = BackofficeFaqsService();
  late final TextEditingController _searchController;
  List<FaqItem> _allItems = <FaqItem>[];
  List<FaqItem> _visibleItems = <FaqItem>[];
  List<FaqCategoryOption> _categories = <FaqCategoryOption>[];
  String? _selectedCategory;
  bool _loading = true;
  String? _warningMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.faqs,
      title: 'FAQs',
      showTopBar: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;
          final verticalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: FaqsPage._contentMaxWidth,
                ),
                child: FaqsOverviewSection(
                  items: _visibleItems,
                  categories: _categories,
                  searchController: _searchController,
                  selectedCategory: _selectedCategory,
                  isLoading: _loading,
                  warningMessage: _warningMessage,
                  onCreate: _openCreateDialog,
                  onCreateCategory: _openCreateCategoryDialog,
                  onEdit: _openEditDialog,
                  onDelete: _confirmDeleteFaq,
                  onSearchChanged: _applyFilters,
                  onCategoryChanged: (value) {
                    setState(() => _selectedCategory = value);
                    _applyFilters(_searchController.text);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _warningMessage = null;
    });

    try {
      final categories = await _service.fetchCategories();
      final items = await _service.fetchFaqs();
      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
        _allItems = List<FaqItem>.of(items);
        _visibleItems = List<FaqItem>.of(items);
        _loading = false;
      });
      _applyFilters(_searchController.text);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _warningMessage = 'Não foi possível carregar as FAQs da API. $error';
      });
    }
  }

  Future<void> _openCreateDialog() async {
    if (_categories.isEmpty) {
      _showMessage('É necessário ter pelo menos uma categoria FAQ disponível.');
      return;
    }

    final result = await showDialog<FaqDialogResult>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (_) => FaqDialog(categories: _categories),
    );

    if (result == null) {
      return;
    }

    try {
      final newItem = await _service.createFaq(
        categoryId: result.categoryId,
        categoryLabel: result.categoryLabel,
        question: result.question,
        answer: result.answer,
      );

      setState(() {
        _allItems.insert(0, newItem);
      });
      _applyFilters(_searchController.text);
      _showMessage('FAQ criada com sucesso.');
    } catch (error) {
      _showMessage('Erro ao criar FAQ: $error');
    }
  }

  Future<void> _openCreateCategoryDialog() async {
    final result = await showDialog<FaqCategoryDialogResult>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (_) => const FaqCategoryDialog(),
    );

    if (result == null) {
      return;
    }

    try {
      final category = await _service.createCategory(
        label: result.label,
        description: result.description,
      );

      setState(() {
        _categories = [category, ..._categories];
        _selectedCategory ??= category.id;
      });
      _applyFilters(_searchController.text);
      _showMessage('Categoria FAQ criada com sucesso.');
    } catch (error) {
      _showMessage('Erro ao criar categoria FAQ: $error');
    }
  }

  Future<void> _openEditDialog(FaqItem item) async {
    final result = await showDialog<FaqDialogResult>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (_) => FaqDialog(categories: _categories, initialItem: item),
    );

    if (result == null) {
      return;
    }

    try {
      final updatedItem = await _service.updateFaq(
        id: item.id,
        categoryId: result.categoryId,
        categoryLabel: result.categoryLabel,
        question: result.question,
        answer: result.answer,
      );

      final index = _allItems.indexWhere((element) => element.id == item.id);
      if (index == -1) {
        return;
      }

      setState(() {
        _allItems[index] = updatedItem;
      });
      _applyFilters(_searchController.text);
      _showMessage('FAQ atualizada com sucesso.');
    } catch (error) {
      _showMessage('Erro ao atualizar FAQ: $error');
    }
  }

  Future<void> _confirmDeleteFaq(FaqItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar FAQ'),
        content: Text('Queres eliminar a FAQ "${item.question}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _service.deleteFaq(item.id);
      setState(() {
        _allItems.removeWhere((element) => element.id == item.id);
      });
      _applyFilters(_searchController.text);
      _showMessage('FAQ eliminada com sucesso.');
    } catch (error) {
      _showMessage('Erro ao eliminar FAQ: $error');
    }
  }

  void _applyFilters(String rawQuery) {
    final query = rawQuery.trim().toLowerCase();

    setState(() {
      _visibleItems = _allItems.where((item) {
        final matchesCategory =
            _selectedCategory == null || item.categoryId == _selectedCategory;
        final matchesQuery =
            query.isEmpty ||
            item.id.toLowerCase().contains(query) ||
            item.categoryLabel.toLowerCase().contains(query) ||
            item.question.toLowerCase().contains(query) ||
            item.answer.toLowerCase().contains(query) ||
            item.status.label.toLowerCase().contains(query) ||
            item.updatedAtLabel.toLowerCase().contains(query);
        return matchesCategory && matchesQuery;
      }).toList();
    });
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
