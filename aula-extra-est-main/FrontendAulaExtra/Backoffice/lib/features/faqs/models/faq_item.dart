import 'package:flutter/material.dart';

class FaqCategoryOption {
  const FaqCategoryOption({
    required this.id,
    required this.label,
    this.description,
  });

  final String id;
  final String label;
  final String? description;
}

enum FaqStatus { published }

extension FaqStatusPresentation on FaqStatus {
  String get label {
    switch (this) {
      case FaqStatus.published:
        return 'Publicado';
    }
  }

  Color get textColor {
    switch (this) {
      case FaqStatus.published:
        return const Color(0xFF067647);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case FaqStatus.published:
        return const Color(0xFFECFDF3);
    }
  }
}

class FaqItem {
  const FaqItem({
    required this.id,
    required this.categoryId,
    required this.categoryLabel,
    required this.question,
    required this.answer,
    required this.status,
    required this.updatedAtLabel,
  });

  final String id;
  final String categoryId;
  final String categoryLabel;
  final String question;
  final String answer;
  final FaqStatus status;
  final String updatedAtLabel;

  FaqItem copyWith({
    String? id,
    String? categoryId,
    String? categoryLabel,
    String? question,
    String? answer,
    FaqStatus? status,
    String? updatedAtLabel,
  }) {
    return FaqItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryLabel: categoryLabel ?? this.categoryLabel,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      status: status ?? this.status,
      updatedAtLabel: updatedAtLabel ?? this.updatedAtLabel,
    );
  }
}
