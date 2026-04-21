import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_layout.dart';
import 'package:flutter/material.dart';

class AvaliacoesProfessorMobileReviewCardData {
  const AvaliacoesProfessorMobileReviewCardData({
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.dateLabel,
    required this.comment,
    required this.subtitle,
  });

  final String name;
  final String? avatarUrl;
  final int rating;
  final String dateLabel;
  final String comment;
  final String subtitle;
}

class AvaliacoesProfessorMobileReviewCard extends StatelessWidget {
  const AvaliacoesProfessorMobileReviewCard({super.key, required this.review});

  final AvaliacoesProfessorMobileReviewCardData review;

  String get _initials {
    final parts = review.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'AE';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = review.avatarUrl?.trim().isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AvaliacoesProfessorLayout.mobileReviewCardRadius,
        ),
        border: Border.all(color: AvaliacoesProfessorColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
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
                width: AvaliacoesProfessorLayout.mobileAvatarSize,
                height: AvaliacoesProfessorLayout.mobileAvatarSize,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: hasAvatar
                    ? Image.network(
                        review.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _Initials(initials: _initials),
                      )
                    : _Initials(initials: _initials),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        color: AvaliacoesProfessorColors.title,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 22 / 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.subtitle,
                      style: const TextStyle(
                        color: AvaliacoesProfessorColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    review.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AvaliacoesProfessorColors.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFFFFB800),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              color: AvaliacoesProfessorColors.text,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 18 / 13,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              review.dateLabel,
              style: const TextStyle(
                color: AvaliacoesProfessorColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 14 / 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 18 / 13,
      ),
    );
  }
}
