import 'package:aula_extra/features/aluno/avaliacoes/models/avaliacao_review.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/star_rating_row.dart';
import 'package:flutter/material.dart';

class AvaliacaoReviewCard extends StatelessWidget {
  const AvaliacaoReviewCard({super.key, required this.review});

  final AvaliacaoReview review;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(34.351, 20.351, 34.351, 20.374),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.374),
        borderRadius: BorderRadius.circular(21.985),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 1.374),
            blurRadius: 4.122,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 1.374),
            blurRadius: 2.748,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.tutorName,
                    style: const TextStyle(
                      fontSize: 24.733,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101828),
                      height: 38.473 / 24.733,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.subject,
                    style: const TextStyle(
                      fontSize: 19.237,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4A5565),
                      height: 27.481 / 19.237,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  StarRatingRow(rating: review.rating),
                  const SizedBox(width: 5.496),
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 19.237,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101828),
                      height: 27.481 / 19.237,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 21.985),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 21.985,
              fontWeight: FontWeight.w400,
              color: Color(0xFF364153),
              height: 32.977 / 21.985,
            ),
          ),
          const SizedBox(height: 21.985),
          Text(
            review.dateLabel,
            style: const TextStyle(
              fontSize: 16.489,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6A7282),
              height: 21.985 / 16.489,
            ),
          ),
        ],
      ),
    );
  }
}
