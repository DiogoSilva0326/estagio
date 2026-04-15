import 'package:aula_extra/core/data/professors/dtos/professor_evaluations_overview_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_layout.dart';
import 'package:aula_extra/features/professor/avaliacoes/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:flutter/material.dart';

enum _AvaliacoesProfessorTab { professor, aulas }

class AvaliacoesProfessorContentSection extends StatefulWidget {
  const AvaliacoesProfessorContentSection({super.key});

  @override
  State<AvaliacoesProfessorContentSection> createState() =>
      _AvaliacoesProfessorContentSectionState();
}

class _AvaliacoesProfessorContentSectionState
    extends State<AvaliacoesProfessorContentSection> {
  final ProfessorsService _service = ProfessorsService();
  late Future<ProfessorEvaluationsOverviewDto> _future;
  _AvaliacoesProfessorTab _selectedTab = _AvaliacoesProfessorTab.professor;

  @override
  void initState() {
    super.initState();
    _future = _service.getMyEvaluations();
  }

  void _refresh() {
    setState(() {
      _future = _service.getMyEvaluations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: AvaliacoesProfessorColors.title,
      fontSize: AvaliacoesProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height:
          AvaliacoesProfessorLayout.titleLineHeight /
          AvaliacoesProfessorLayout.titleFontSize,
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
                  child: FutureBuilder<ProfessorEvaluationsOverviewDto>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (snapshot.hasError) {
                        return _ErrorState(
                          titleStyle: titleStyle,
                          message:
                              snapshot.error?.toString() ??
                              'Erro ao carregar avaliações do professor',
                          onRetry: _refresh,
                        );
                      }

                      final data =
                          snapshot.data ??
                          ProfessorEvaluationsOverviewDto(
                            professorSummary: ProfessorEvaluationSummaryDto(
                              averageRating: 0,
                              totalReviews: 0,
                            ),
                            lessonSummary: ProfessorEvaluationSummaryDto(
                              averageRating: 0,
                              totalReviews: 0,
                            ),
                            professorReviews: const [],
                            lessonReviews: const [],
                          );

                      final activeSection =
                          _selectedTab == _AvaliacoesProfessorTab.professor
                          ? _SectionBlock(
                              title: 'Avaliações feitas ao professor',
                              emptyMessage:
                                  'Ainda não existem avaliações submetidas diretamente ao seu perfil.',
                              children: data.professorReviews
                                  .map(
                                    (review) => _ReviewCard(
                                      review: _ReviewCardData(
                                        name: _normalizeName(
                                          review.studentName,
                                        ),
                                        avatarUrl: review.studentAvatarUrl,
                                        rating: review.rating,
                                        dateLabel: _formatDate(
                                          review.createdAt,
                                        ),
                                        comment:
                                            review.comment ??
                                            'Sem comentário adicional.',
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                            )
                          : _SectionBlock(
                              title: 'Avaliações submetidas às aulas',
                              emptyMessage:
                                  'Ainda não existem avaliações submetidas às suas aulas.',
                              children: data.lessonReviews
                                  .map(
                                    (review) => _ReviewCard(
                                      review: _ReviewCardData(
                                        name: _normalizeName(
                                          review.studentName,
                                        ),
                                        avatarUrl: review.studentAvatarUrl,
                                        rating: review.rating,
                                        dateLabel: _formatDate(
                                          review.createdAt,
                                        ),
                                        comment:
                                            review.comment ??
                                            'Sem comentário adicional.',
                                        contextTitle: review.lessonTitle,
                                        contextSubtitle: _formatLessonWindow(
                                          review.scheduledStart,
                                          review.scheduledEnd,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                            );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: AvaliacoesProfessorLayout.titleLineHeight,
                            child: Text('Avaliações', style: titleStyle),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Consulte as avaliações recebidas no seu perfil e nas aulas dadas.',
                            style: TextStyle(
                              color: AvaliacoesProfessorColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 28.868),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final stack = constraints.maxWidth < 980;
                              if (stack) {
                                return Column(
                                  children: [
                                    _SummaryCard(
                                      average:
                                          data.professorSummary.averageRating,
                                      totalLabel:
                                          '${data.professorSummary.totalReviews} avaliações',
                                      label: 'Avaliações feitas ao professor',
                                    ),
                                    const SizedBox(height: 16),
                                    _SummaryCard(
                                      average: data.lessonSummary.averageRating,
                                      totalLabel:
                                          '${data.lessonSummary.totalReviews} avaliações',
                                      label: 'Avaliações submetidas às aulas',
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: _SummaryCard(
                                      average:
                                          data.professorSummary.averageRating,
                                      totalLabel:
                                          '${data.professorSummary.totalReviews} avaliações',
                                      label: 'Avaliações feitas ao professor',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _SummaryCard(
                                      average: data.lessonSummary.averageRating,
                                      totalLabel:
                                          '${data.lessonSummary.totalReviews} avaliações',
                                      label: 'Avaliações submetidas às aulas',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 28.868),
                          _ProfessorTabs(
                            selectedTab: _selectedTab,
                            onChanged: (tab) {
                              setState(() {
                                _selectedTab = tab;
                              });
                            },
                          ),
                          const SizedBox(height: 28.868),
                          activeSection,
                        ],
                      );
                    },
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

class _ProfessorTabs extends StatelessWidget {
  const _ProfessorTabs({required this.selectedTab, required this.onChanged});

  final _AvaliacoesProfessorTab selectedTab;
  final ValueChanged<_AvaliacoesProfessorTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          _ProfessorTabButton(
            label: 'Professor',
            selected: selectedTab == _AvaliacoesProfessorTab.professor,
            onTap: () => onChanged(_AvaliacoesProfessorTab.professor),
          ),
          const SizedBox(width: 28),
          _ProfessorTabButton(
            label: 'Aulas',
            selected: selectedTab == _AvaliacoesProfessorTab.aulas,
            onTap: () => onChanged(_AvaliacoesProfessorTab.aulas),
          ),
        ],
      ),
    );
  }
}

class _ProfessorTabButton extends StatelessWidget {
  const _ProfessorTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AvaliacoesProfessorColors.summaryGradientTop
                    : AvaliacoesProfessorColors.muted,
                fontSize: 18,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: 120,
              decoration: BoxDecoration(
                color: selected
                    ? AvaliacoesProfessorColors.summaryGradientTop
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.titleStyle,
    required this.message,
    required this.onRetry,
  });

  final TextStyle titleStyle;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AvaliacoesProfessorLayout.titleLineHeight,
          child: Text('Avaliações', style: titleStyle),
        ),
        const SizedBox(height: 16),
        Text(message, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.average,
    required this.totalLabel,
    required this.label,
  });

  final double average;
  final String totalLabel;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AvaliacoesProfessorLayout.summaryCardHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            AvaliacoesProfessorLayout.summaryCardRadius,
          ),
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
                      height:
                          AvaliacoesProfessorLayout.summaryValueLineHeight /
                          AvaliacoesProfessorLayout.summaryValueFontSize,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9.623),
              Opacity(
                opacity: 0.9,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AvaliacoesProfessorLayout.summaryLabelFontSize,
                    fontWeight: FontWeight.w400,
                    height:
                        AvaliacoesProfessorLayout.summaryLabelLineHeight /
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
                    height:
                        AvaliacoesProfessorLayout.summarySubLabelLineHeight /
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

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.title,
    required this.emptyMessage,
    required this.children,
  });

  final String title;
  final String emptyMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AvaliacoesProfessorColors.title,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        if (children.isEmpty)
          Text(
            emptyMessage,
            style: const TextStyle(
              color: AvaliacoesProfessorColors.muted,
              fontSize: 16,
            ),
          )
        else
          Column(
            children: List.generate(children.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == children.length - 1
                      ? 0
                      : AvaliacoesProfessorLayout.listGap,
                ),
                child: children[index],
              );
            }),
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _ReviewCardData review;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          AvaliacoesProfessorLayout.reviewCardRadius,
        ),
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
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileAvatar(
                        name: review.name,
                        avatarUrl: review.avatarUrl,
                      ),
                      const SizedBox(width: 14.434),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.name,
                              style: const TextStyle(
                                color: AvaliacoesProfessorColors.title,
                                fontSize: AvaliacoesProfessorLayout
                                    .reviewerNameFontSize,
                                fontWeight: FontWeight.w500,
                                height:
                                    AvaliacoesProfessorLayout
                                        .reviewerNameLineHeight /
                                    AvaliacoesProfessorLayout
                                        .reviewerNameFontSize,
                              ),
                            ),
                            const SizedBox(height: 4.811),
                            _StarRating(rating: review.rating),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  review.dateLabel,
                  style: const TextStyle(
                    color: AvaliacoesProfessorColors.muted,
                    fontSize: AvaliacoesProfessorLayout.dateFontSize,
                    fontWeight: FontWeight.w400,
                    height:
                        AvaliacoesProfessorLayout.dateLineHeight /
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
                height:
                    AvaliacoesProfessorLayout.commentLineHeight /
                    AvaliacoesProfessorLayout.commentFontSize,
              ),
            ),
            if (review.contextTitle != null) ...[
              const SizedBox(height: 14.434),
              Text(
                review.contextTitle!,
                style: const TextStyle(
                  color: AvaliacoesProfessorColors.title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (review.contextSubtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  review.contextSubtitle!,
                  style: const TextStyle(
                    color: AvaliacoesProfessorColors.muted,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl?.trim();
    final hasAvatar = url != null && url.isNotEmpty;

    return SizedBox(
      height: AvaliacoesProfessorLayout.avatarSize,
      width: AvaliacoesProfessorLayout.avatarSize,
      child: ClipOval(
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
          child: hasAvatar
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, error, stackTrace) =>
                      _AvatarInitials(name: name),
                )
              : _AvatarInitials(name: name),
        ),
      ),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _buildInitials(name),
        style: const TextStyle(
          color: Colors.white,
          fontSize: AvaliacoesProfessorLayout.avatarTextFontSize,
          fontWeight: FontWeight.w500,
          height:
              AvaliacoesProfessorLayout.avatarTextLineHeight /
              AvaliacoesProfessorLayout.avatarTextFontSize,
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

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

class _ReviewCardData {
  const _ReviewCardData({
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.dateLabel,
    required this.comment,
    this.contextTitle,
    this.contextSubtitle,
  });

  final String name;
  final String? avatarUrl;
  final int rating;
  final String dateLabel;
  final String comment;
  final String? contextTitle;
  final String? contextSubtitle;
}

String _normalizeName(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? 'Aluno' : trimmed;
}

String _buildInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);

  if (parts.isEmpty) return 'A';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

String _formatDate(DateTime? dateTime) {
  if (dateTime == null) return '';
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();
  return '$day/$month/$year';
}

String? _formatLessonWindow(DateTime? start, DateTime? end) {
  if (start == null && end == null) return null;
  final startLabel = start == null
      ? null
      : '${_formatDate(start)} • ${_formatTime(start)}';
  if (end == null) return startLabel;
  final endTime = _formatTime(end);
  return startLabel == null ? endTime : '$startLabel - $endTime';
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
