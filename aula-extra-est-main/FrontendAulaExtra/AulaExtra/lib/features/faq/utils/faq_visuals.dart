import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:flutter/material.dart';

class FaqVisuals {
  static const List<String> preferredOrder = [
    'Para Alunos',
    'Para Explicadores',
    'Pagamentos e Preços',
    'Aulas e Tecnologia',
    'Conta e Segurança',
  ];

  static int compareCategories(String left, String right) {
    final leftIndex = preferredOrder.indexOf(left);
    final rightIndex = preferredOrder.indexOf(right);

    if (leftIndex >= 0 && rightIndex >= 0) {
      return leftIndex.compareTo(rightIndex);
    }
    if (leftIndex >= 0) return -1;
    if (rightIndex >= 0) return 1;
    return left.toLowerCase().compareTo(right.toLowerCase());
  }

  static IconData iconForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'para alunos':
        return Icons.school_outlined;
      case 'para explicadores':
        return Icons.person_outline;
      case 'pagamentos e preços':
        return Icons.payments_outlined;
      case 'aulas e tecnologia':
        return Icons.videocam_outlined;
      case 'conta e segurança':
        return Icons.lock_outline;
      default:
        return Icons.help_outline;
    }
  }

  static Color accentColorForCategory(String category) {
    switch (category.trim().toLowerCase()) {
      case 'para alunos':
        return const Color(0xFF2B7FFF);
      case 'para explicadores':
        return const Color(0xFF00C950);
      case 'pagamentos e preços':
        return const Color(0xFFFF6900);
      case 'aulas e tecnologia':
        return const Color(0xFFAD46FF);
      case 'conta e segurança':
        return const Color(0xFFFB2C36);
      default:
        return FaqColors.orange;
    }
  }
}
