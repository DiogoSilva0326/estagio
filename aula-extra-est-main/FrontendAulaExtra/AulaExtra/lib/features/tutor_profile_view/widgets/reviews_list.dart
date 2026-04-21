import 'package:aula_extra/core/data/professors/dtos/public_professor_profile_dto.dart';
import 'package:aula_extra/features/tutor_profile_view/widgets/review_card.dart';
import 'package:flutter/material.dart';

class ReviewsList extends StatelessWidget {
  const ReviewsList({super.key, required this.reviews});

  final List<PublicProfessorReviewDto> reviews;

  String _formatRelativeDate(DateTime? date) {
    if (date == null) return 'Recentemente';
    final now = DateTime.now();
    final localDate = date.toLocal();
    final diff = now.difference(localDate);

    if (diff.inDays >= 60) {
      final months = (diff.inDays / 30).floor();
      return months <= 1 ? '1 mês atrás' : '$months meses atrás';
    }
    if (diff.inDays >= 14) {
      final weeks = (diff.inDays / 7).floor();
      return weeks <= 1 ? '1 semana atrás' : '$weeks semanas atrás';
    }
    if (diff.inDays >= 1) {
      return diff.inDays == 1 ? 'Ontem' : '${diff.inDays} dias atrás';
    }
    if (diff.inHours >= 1) {
      return diff.inHours == 1 ? '1 hora atrás' : '${diff.inHours} horas atrás';
    }
    if (diff.inMinutes >= 1) {
      return diff.inMinutes == 1
          ? '1 minuto atrás'
          : '${diff.inMinutes} minutos atrás';
    }

    return 'Agora mesmo';
  }

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Text(
        'Este professor ainda não recebeu avaliações públicas.',
        style: TextStyle(fontSize: 18, height: 1.6, color: Color(0xFF6B7280)),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < reviews.length; index++) ...[
          ReviewCard(
            name: reviews[index].reviewerName,
            when: _formatRelativeDate(reviews[index].createdAt),
            rating: reviews[index].rating,
            text: reviews[index].comment ?? 'Sem comentário adicional.',
            avatarUrl: reviews[index].reviewerImageUrl,
          ),
          if (index < reviews.length - 1) const SizedBox(height: 20.426),
        ],
      ],
    );
  }
}
