class FaqCategoryDto {
  FaqCategoryDto({
    required this.idFaqCategory,
    required this.category,
    required this.faqCount,
    this.description,
  });

  final String idFaqCategory;
  final String category;
  final int faqCount;
  final String? description;

  factory FaqCategoryDto.fromJson(Map<String, dynamic> json) {
    final rawCount = json['faqCount'] ?? json['FaqCount'] ?? json['faq_count'];
    final count = rawCount is num
        ? rawCount.toInt()
        : int.tryParse(rawCount?.toString() ?? '') ?? 0;

    return FaqCategoryDto(
      idFaqCategory:
          (json['idFaqCategory'] ?? json['IdFaqCategory'] ?? json['id_faq_category'])
              ?.toString() ?? '',
      category:
          (json['category'] ?? json['Category'] ?? json['name'] ?? json['Name'])
              ?.toString() ?? '',
      faqCount: count,
      description: (json['description'] ?? json['Description'])?.toString(),
    );
  }
}
