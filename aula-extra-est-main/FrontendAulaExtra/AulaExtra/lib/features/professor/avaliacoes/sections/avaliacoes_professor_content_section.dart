import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_layout.dart';
import 'package:aula_extra/features/professor/avaliacoes/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:flutter/material.dart';

class AvaliacoesProfessorContentSection extends StatelessWidget {
  const AvaliacoesProfessorContentSection({
    super.key,
  });

  static const _summaryAverage = 4.7;
  static const _summaryTotalLabel = '5 avaliações totais';

  static const List<_ReviewData> _reviews = [
    _ReviewData(
      initials: 'JS',
      name: 'João Silva',
      rating: 4,
      dateLabel: '20 Jan 2026',
      comment: 'Excelente explicador! Muito paciente e didático.',
    ),
    _ReviewData(
      initials: 'MS',
      name: 'Maria Santos',
      rating: 4,
      dateLabel: '18 Jan 2026',
      comment: 'Ótimas aulas de Física. Aprendi muito!',
    ),
    _ReviewData(
      initials: 'PC',
      name: 'Pedro Costa',
      rating: 4,
      dateLabel: '15 Jan 2026',
      comment: 'O melhor professor de Inglês que já tive. Recomendo!',
    ),
    _ReviewData(
      initials: 'AR',
      name: 'Ana Rodrigues',
      rating: 5,
      dateLabel: '12 Jan 2026',
      comment: 'Muito bom, mas às vezes a explicação poderia ser mais detalhada.',
    ),
    _ReviewData(
      initials: 'CF',
      name: 'Carlos Ferreira',
      rating: 5,
      dateLabel: '10 Jan 2026',
      comment: 'Sempre disponível e preparado. Excelente profissional!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: AvaliacoesProfessorColors.title,
      fontSize: AvaliacoesProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height: AvaliacoesProfessorLayout.titleLineHeight / AvaliacoesProfessorLayout.titleFontSize,
    );

    return Container(
      color: AvaliacoesProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: AvaliacoesProfessorLayout.pageLeftPadding,
            right: AvaliacoesProfessorLayout.pageRightPadding,
            top: AvaliacoesProfessorLayout.pageTopPadding,
            bottom: AvaliacoesProfessorLayout.pageBottomPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AvaliacoesProfessorLayout.contentPadding,
                    AvaliacoesProfessorLayout.contentPadding,
                    AvaliacoesProfessorLayout.contentPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: AvaliacoesProfessorLayout.titleLineHeight,
                        child: Text('Avaliações', style: titleStyle),
                      ),
                      const SizedBox(height: 28.868),
                      _SummaryCard(
                        average: _summaryAverage,
                        totalLabel: _summaryTotalLabel,
                      ),
                      const SizedBox(height: 28.868),
                      Column(
                        children: List.generate(_reviews.length, (index) {
                          final review = _reviews[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == _reviews.length - 1
                                  ? 0
                                  : AvaliacoesProfessorLayout.listGap,
                            ),
                            child: _ReviewCard(review: review),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.average,
    required this.totalLabel,
  });

  final double average;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AvaliacoesProfessorLayout.summaryCardHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AvaliacoesProfessorLayout.summaryCardRadius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AvaliacoesProfessorColors.summaryGradientTop,
              AvaliacoesProfessorColors.summaryGradientBottom,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 18.042,
              offset: const Offset(0, 12.028),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 7.217,
              offset: const Offset(0, 4.811),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AvaliacoesProfessorLayout.summaryCardPaddingTop,
            AvaliacoesProfessorLayout.summaryCardPaddingTop,
            AvaliacoesProfessorLayout.summaryCardPaddingTop,
            0,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: AvaliacoesProfessorLayout.summaryIconSize,
                  ),
                  const SizedBox(width: 9.623),
                  Text(
                    average.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AvaliacoesProfessorLayout.summaryValueFontSize,
                      fontWeight: FontWeight.w700,
                      height: AvaliacoesProfessorLayout.summaryValueLineHeight /
                          AvaliacoesProfessorLayout.summaryValueFontSize,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9.623),
              Opacity(
                opacity: 0.9,
                child: Text(
                  'Avaliação Média',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AvaliacoesProfessorLayout.summaryLabelFontSize,
                    fontWeight: FontWeight.w400,
                    height: AvaliacoesProfessorLayout.summaryLabelLineHeight /
                        AvaliacoesProfessorLayout.summaryLabelFontSize,
                  ),
                ),
              ),
              const SizedBox(height: 9.623),
              Opacity(
                opacity: 0.8,
                child: Text(
                  totalLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AvaliacoesProfessorLayout.summarySubLabelFontSize,
                    fontWeight: FontWeight.w400,
                    height: AvaliacoesProfessorLayout.summarySubLabelLineHeight /
                        AvaliacoesProfessorLayout.summarySubLabelFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
  });

  final _ReviewData review;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AvaliacoesProfessorLayout.reviewCardRadius),
        border: Border.all(
          color: AvaliacoesProfessorColors.cardBorder,
          width: AvaliacoesProfessorLayout.reviewCardBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 7.217,
            offset: const Offset(0, 4.811),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4.811,
            offset: const Offset(0, 2.406),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AvaliacoesProfessorLayout.reviewCardPadding,
          AvaliacoesProfessorLayout.reviewCardPadding,
          AvaliacoesProfessorLayout.reviewCardPadding,
          1.203,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _InitialsAvatar(initials: review.initials),
                    const SizedBox(width: 14.434),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review.name,
                          style: const TextStyle(
                            color: AvaliacoesProfessorColors.title,
                            fontSize: AvaliacoesProfessorLayout.reviewerNameFontSize,
                            fontWeight: FontWeight.w500,
                            height: AvaliacoesProfessorLayout.reviewerNameLineHeight /
                                AvaliacoesProfessorLayout.reviewerNameFontSize,
                          ),
                        ),
                        const SizedBox(height: 4.811),
                        _StarRating(rating: review.rating),
                      ],
                    ),
                  ],
                ),
                Text(
                  review.dateLabel,
                  style: const TextStyle(
                    color: AvaliacoesProfessorColors.muted,
                    fontSize: AvaliacoesProfessorLayout.dateFontSize,
                    fontWeight: FontWeight.w400,
                    height: AvaliacoesProfessorLayout.dateLineHeight /
                        AvaliacoesProfessorLayout.dateFontSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.434),
            Text(
              review.comment,
              style: const TextStyle(
                color: AvaliacoesProfessorColors.text,
                fontSize: AvaliacoesProfessorLayout.commentFontSize,
                fontWeight: FontWeight.w400,
                height: AvaliacoesProfessorLayout.commentLineHeight /
                    AvaliacoesProfessorLayout.commentFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({
    required this.initials,
  });

  final String initials;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AvaliacoesProfessorLayout.avatarSize,
      width: AvaliacoesProfessorLayout.avatarSize,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AvaliacoesProfessorColors.avatarGradientTop,
              AvaliacoesProfessorColors.avatarGradientBottom,
            ],
          ),
        ),
        child: Center(
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AvaliacoesProfessorLayout.avatarTextFontSize,
              fontWeight: FontWeight.w500,
              height: AvaliacoesProfessorLayout.avatarTextLineHeight /
                  AvaliacoesProfessorLayout.avatarTextFontSize,
            ),
          ),
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({
    required this.rating,
  });

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final filled = index < rating;

        return Padding(
          padding: EdgeInsets.only(
            right: index == 4 ? 0 : AvaliacoesProfessorLayout.starsGap,
          ),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: AvaliacoesProfessorColors.star,
            size: AvaliacoesProfessorLayout.starSize,
          ),
        );
      }),
    );
  }
}

class _ReviewData {
  const _ReviewData({
    required this.initials,
    required this.name,
    required this.rating,
    required this.dateLabel,
    required this.comment,
  });

  final String initials;
  final String name;
  final int rating;
  final String dateLabel;
  final String comment;
}
