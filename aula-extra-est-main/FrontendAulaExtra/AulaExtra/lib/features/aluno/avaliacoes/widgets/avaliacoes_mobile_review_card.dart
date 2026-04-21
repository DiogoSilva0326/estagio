import 'package:aula_extra/features/aluno/avaliacoes/constants/avaliacoes_constants.dart';
import 'package:aula_extra/features/aluno/avaliacoes/models/avaliacao_review.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/star_rating_row.dart';
import 'package:flutter/material.dart';

class AvaliacoesMobileReviewCard extends StatelessWidget {
  const AvaliacoesMobileReviewCard({super.key, required this.review});

  final AvaliacaoReview review;

  String get _initials {
    final parts = review.tutorName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'AE';
    }
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: AvaliacoesConstants.mobileSurfaceColor,
        borderRadius: BorderRadius.circular(
          AvaliacoesConstants.mobileCardRadius,
        ),
        border: Border.all(color: AvaliacoesConstants.mobileBorderColor),
        boxShadow: AvaliacoesConstants.mobileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 18 / 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.tutorName,
                      style: AvaliacoesConstants.mobileCardTitleStyle.copyWith(
                        fontSize: 16,
                        height: 22 / 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.subject,
                      style: AvaliacoesConstants.mobileCardSubtitleStyle
                          .copyWith(fontSize: 12, height: 16 / 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        review.rating.toStringAsFixed(1),
                        style: AvaliacoesConstants.mobileValueStyle.copyWith(
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Color(0xFFFFB800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  StarRatingRow(
                    rating: review.rating,
                    starSize: 12,
                    spacing: 1,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: AvaliacoesConstants.mobileBodyStyle.copyWith(
              fontSize: 13,
              height: 18 / 13,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              review.dateLabel,
              style: AvaliacoesConstants.mobileMetaStyle.copyWith(
                fontSize: 11,
                height: 14 / 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
