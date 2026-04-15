class FaqItemDto {
  FaqItemDto({
    required this.idFaq,
    required this.idFaqCategory,
    required this.question,
    required this.description,
    required this.categoryName,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final String idFaq;
  final String idFaqCategory;
  final String question;
  final String description;
  final String categoryName;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory FaqItemDto.fromJson(Map<String, dynamic> json) {
    return FaqItemDto(
      idFaq: (json['idFaq'] ?? json['IdFaq'] ?? json['id_faq'])?.toString() ?? '',
      idFaqCategory:
        (json['idFaqCategory'] ?? json['IdFaqCategory'] ?? json['id_faq_category'])
          ?.toString() ?? '',
      question: (json['question'] ?? json['Question'])?.toString() ?? '',
      description: (json['description'] ?? json['Description'])?.toString() ?? '',
      categoryName:
        (json['categoryName'] ?? json['CategoryName'] ?? json['category'] ?? json['Category'])
          ?.toString() ?? '',
      userId: (json['userId'] ?? json['UserId'] ?? json['user_id'])?.toString(),
      createdAt: _tryParseDateTime(json['createdAt'] ?? json['CreatedAt'] ?? json['created_at']),
      updatedAt: _tryParseDateTime(json['updatedAt'] ?? json['UpdatedAt'] ?? json['updated_at']),
    );
  }

  static DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
