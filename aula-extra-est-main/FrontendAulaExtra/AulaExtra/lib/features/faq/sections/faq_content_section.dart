import 'package:aula_extra/core/data/faq/dtos/faq_category_dto.dart';
import 'package:aula_extra/core/data/faq/dtos/faq_item_dto.dart';
import 'package:aula_extra/core/data/faq/faq_api.dart';
import 'package:aula_extra/core/data/faq/faq_service.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:aula_extra/features/faq/utils/faq_visuals.dart';
import 'package:aula_extra/features/faq/widgets/faq_hero_block.dart';
import 'package:aula_extra/features/faq/widgets/faq_main_block.dart';
import 'package:flutter/material.dart';

class FaqContentSection extends StatefulWidget {
  const FaqContentSection({super.key});

  @override
  State<FaqContentSection> createState() => _FaqContentSectionState();
}

class _FaqContentSectionState extends State<FaqContentSection> {
  final FaqService _faqService = FaqService();
  late final TextEditingController _searchController;

  List<FaqCategoryDto> _categories = const [];
  List<FaqItemDto> _faqs = const [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _faqService.getPublicCategories(),
        _faqService.getPublicFaqs(),
      ]);

      final categories = (results[0] as List<FaqCategoryDto>).toList()
        ..sort(
          (left, right) => FaqVisuals.compareCategories(
            left.category,
            right.category,
          ),
        );

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _faqs = (results[1] as List<FaqItemDto>).toList();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error is FaqException ? error.message : 'Ocorreu um erro ao carregar as FAQs.';
      });
    }
  }

  Future<void> _loadFaqs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final faqs = await _faqService.getPublicFaqs(
        idFaqCategory: _selectedCategoryId,
        query: _normalizedQuery,
      );

      if (!mounted) return;
      setState(() {
        _faqs = faqs;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error is FaqException ? error.message : 'Ocorreu um erro ao carregar as FAQs.';
      });
    }
  }

  String? get _normalizedQuery {
    final value = _searchController.text.trim();
    return value.isEmpty ? null : value;
  }

  void _handleCategoryTap(String idFaqCategory) {
    final nextCategory = _selectedCategoryId == idFaqCategory
        ? null
        : idFaqCategory;
    setState(() {
      _selectedCategoryId = nextCategory;
    });
    _loadFaqs();
  }

  List<FaqCategoryData> get _categoryData {
    return _categories
        .map(
          (category) => FaqCategoryData(
            id: category.idFaqCategory,
            label: category.category,
            icon: FaqVisuals.iconForCategory(category.category),
            selected: _selectedCategoryId == category.idFaqCategory,
          ),
        )
        .toList(growable: false);
  }

  List<FaqGroupData> get _groupData {
    final grouped = <String, List<FaqItemDto>>{};
    for (final faq in _faqs) {
      grouped.putIfAbsent(faq.categoryName, () => <FaqItemDto>[]).add(faq);
    }

    final categories = grouped.keys.toList()
      ..sort(FaqVisuals.compareCategories);

    return categories.map((category) {
      final questions = grouped[category] ?? const <FaqItemDto>[];
      final count = questions.length;
      return FaqGroupData(
        accentColor: FaqVisuals.accentColorForCategory(category),
        title: category,
        questionCountText: '$count ${count == 1 ? 'pergunta' : 'perguntas'}',
        questions: questions
            .map(
              (faq) => FaqQuestionData(
                question: faq.question,
                answer: faq.description,
              ),
            )
            .toList(growable: false),
        initiallyExpanded: categories.first == category,
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FaqHeroBlock(
          searchController: _searchController,
          onSearchPressed: _loadFaqs,
        ),
        const SizedBox(height: 61.252),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 66.36),
          child: FaqMainBlock(
            categories: _categoryData,
            groups: _groupData,
            onCategoryTap: _handleCategoryTap,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onRetry: _loadInitialData,
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
