import 'package:aula_extra/core/data/professors/dtos/professor_evaluations_overview_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart'; 
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 
import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_colors.dart';
import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_layout.dart';
import 'package:aula_extra/features/professor/avaliacoes/constants/avaliacoes_professor_tabs.dart';
import 'package:aula_extra/features/professor/avaliacoes/widgets/avaliacoes_professor_mobile_intro.dart';
import 'package:aula_extra/features/professor/avaliacoes/widgets/avaliacoes_professor_mobile_mode_tabs.dart';
import 'package:aula_extra/features/professor/avaliacoes/widgets/avaliacoes_professor_mobile_review_card.dart';
import 'package:aula_extra/features/professor/avaliacoes/widgets/avaliacoes_professor_mobile_stat_card.dart';
import 'package:aula_extra/features/professor/avaliacoes/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

class AvaliacoesProfessorContentSection extends StatefulWidget {
  const AvaliacoesProfessorContentSection({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  State<AvaliacoesProfessorContentSection> createState() =>
      _AvaliacoesProfessorContentSectionState();
}

class _AvaliacoesProfessorContentSectionState
    extends State<AvaliacoesProfessorContentSection> {
  final ProfessorsService _service = ProfessorsService();
  late Future<ProfessorEvaluationsOverviewDto> _future;
  AvaliacoesProfessorTab _selectedTab = AvaliacoesProfessorTab.professor;

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

  ProfessorEvaluationsOverviewDto get _emptyData =>
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

  ProfessorEvaluationSummaryDto _summaryForTab(
    ProfessorEvaluationsOverviewDto data,
  ) {
    switch (_selectedTab) {
      case AvaliacoesProfessorTab.professor:
        return data.professorSummary;
      case AvaliacoesProfessorTab.aulas:
        return data.lessonSummary;
    }
  }

  String _emptyMessageForTab(TeachingRoleConfig config) {
    switch (_selectedTab) {
      case AvaliacoesProfessorTab.professor:
        return 'Ainda não existem avaliações submetidas diretamente ao seu perfil.';
      case AvaliacoesProfessorTab.aulas:
        return config.avaliacoes.sessionEmptyLabel;
    }
  }

  List<Widget> _reviewCards(
    ProfessorEvaluationsOverviewDto data, {
    required bool isMobile,
    required TeachingRoleConfig config,
  }) {
    if (_selectedTab == AvaliacoesProfessorTab.professor) {
      return data.professorReviews
          .map((review) {
            final normalizedName = _normalizeName(review.studentName, config);
            if (isMobile) {
              return AvaliacoesProfessorMobileReviewCard(
                review: AvaliacoesProfessorMobileReviewCardData(
                  name: normalizedName,
                  avatarUrl: review.studentAvatarUrl,
                  rating: review.rating,
                  dateLabel: _formatDate(review.createdAt),
                  comment: review.comment ?? 'Sem comentário adicional.',
                  subtitle: 'Avaliação ao ${config.roleName.toLowerCase()}',
                ),
              );
            }

            return _ReviewCard(
              review: _ReviewCardData(
                name: normalizedName,
                avatarUrl: review.studentAvatarUrl,
                rating: review.rating,
                dateLabel: _formatDate(review.createdAt),
                comment: review.comment ?? 'Sem comentário adicional.',
              ),
            );
          })
          .toList(growable: false);
    }

    return data.lessonReviews
        .map((review) {
          final normalizedName = _normalizeName(review.studentName, config);
          final lessonWindow = _formatLessonWindow(
            review.scheduledStart,
            review.scheduledEnd,
          );
          if (isMobile) {
            final lessonTitle = review.lessonTitle.trim();

            return AvaliacoesProfessorMobileReviewCard(
              review: AvaliacoesProfessorMobileReviewCardData(
                name: normalizedName,
                avatarUrl: review.studentAvatarUrl,
                rating: review.rating,
                dateLabel: _formatDate(review.createdAt),
                comment: review.comment ?? 'Sem comentário adicional.',
                subtitle: lessonTitle.isNotEmpty
                    ? lessonTitle
                    : (lessonWindow ?? 'Avaliação da ${config.sessionsLabel}'),
              ),
            );
          }

          return _ReviewCard(
            review: _ReviewCardData(
              name: normalizedName,
              avatarUrl: review.studentAvatarUrl,
              rating: review.rating,
              dateLabel: _formatDate(review.createdAt),
              comment: review.comment ?? 'Sem comentário adicional.',
              contextTitle: review.lessonTitle,
              contextSubtitle: lessonWindow,
            ),
          );
        })
        .toList(growable: false);
  }

  Widget _buildDesktopContent(
    ProfessorEvaluationsOverviewDto data,
    TextStyle titleStyle,
    TeachingRoleConfig config,
  ) {

    final sectionTitle = _selectedTab == AvaliacoesProfessorTab.professor 
      ? 'Perfil do ${config.roleName}' 
      : config.avaliacoes.sessionTabLabel;

    final activeSection = _SectionBlock(
      title: sectionTitle,
      emptyMessage: _emptyMessageForTab(config),
      children: _reviewCards(data, isMobile: false, config: config),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: AvaliacoesProfessorLayout.titleLineHeight,
          child: Text('Avaliações', style: titleStyle),
        ),
        const SizedBox(height: 12),
        Text(
          'Consulte as avaliações recebidas no seu perfil e nas ${config.sessionsLabel} dadas.',
          style: const TextStyle(
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
                    average: data.professorSummary.averageRating,
                    totalLabel:
                        '${data.professorSummary.totalReviews} avaliações',
                    label: 'Avaliações feitas ao ${config.roleName.toLowerCase()}',
                    primaryColor: config.primaryColor, 
                    isOrange: config.roleName == 'Explicador',
                  ),
                  const SizedBox(height: 16),
                  _SummaryCard(
                    average: data.lessonSummary.averageRating,
                    totalLabel: '${data.lessonSummary.totalReviews} avaliações',
                    label: config.avaliacoes.sessionStatsLabel,
                    primaryColor: config.primaryColor,
                    isOrange: config.roleName == 'Explicador',
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    average: data.professorSummary.averageRating,
                    totalLabel:
                        '${data.professorSummary.totalReviews} avaliações',
                    label: 'Avaliações feitas ao ${config.roleName.toLowerCase()}',
                    primaryColor: config.primaryColor,
                    isOrange: config.roleName == 'Explicador',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    average: data.lessonSummary.averageRating,
                    totalLabel: '${data.lessonSummary.totalReviews} avaliações',
                    label: config.avaliacoes.sessionStatsLabel,
                    primaryColor: config.primaryColor,
                    isOrange: config.roleName == 'Explicador',
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 28.868),
        _ProfessorTabs(
          selectedTab: _selectedTab,
          config: config, 
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
  }

  Widget _buildMobileContent(ProfessorEvaluationsOverviewDto data, TeachingRoleConfig config) {
    final summary = _summaryForTab(data);
    final cards = _reviewCards(data, isMobile: true, config: config);
    
    final countLabel = _selectedTab == AvaliacoesProfessorTab.professor 
      ? 'ao perfil' 
      : 'às ${config.sessionsLabel}';

    return Container(
      width: double.infinity,
      color: AvaliacoesProfessorColors.background,
      padding: const EdgeInsets.fromLTRB(
        AvaliacoesProfessorLayout.mobileHorizontalPadding,
        AvaliacoesProfessorLayout.mobileTopPadding,
        AvaliacoesProfessorLayout.mobileHorizontalPadding,
        AvaliacoesProfessorLayout.mobileBottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvaliacoesProfessorMobileIntro(
            title: 'Avaliações',
            subtitle:
                'Consulte as avaliações recebidas no seu perfil e nas ${config.sessionsLabel} dadas.',
          ),
          const SizedBox(height: AvaliacoesProfessorLayout.mobileSectionGap),
          AvaliacoesProfessorMobileModeTabs(
            selectedTab: _selectedTab,
            onChanged: (tab) {
              setState(() {
                _selectedTab = tab;
              });
            },
          ),
          const SizedBox(height: AvaliacoesProfessorLayout.mobileSectionGap),
          AvaliacoesProfessorMobileStatCard(
            value: summary.averageRating.toStringAsFixed(1),
            label: 'Média de avaliações', 
          ),
          const SizedBox(height: 12),
          Text(
            '${summary.totalReviews} avaliações $countLabel',
            style: const TextStyle(
              color: AvaliacoesProfessorColors.title,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 12),
          if (cards.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  AvaliacoesProfessorLayout.mobileCardRadius,
                ),
                border: Border.all(color: AvaliacoesProfessorColors.cardBorder),
              ),
              child: Text(
                _emptyMessageForTab(config),
                style: const TextStyle(
                  color: AvaliacoesProfessorColors.muted,
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
            )
          else
            Column(
              children: List.generate(cards.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == cards.length - 1 ? 0 : 14,
                  ),
                  child: cards[index],
                );
              }),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);

    final titleStyle = TextStyle(
      color: AvaliacoesProfessorColors.title,
      fontSize: AvaliacoesProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height:
          AvaliacoesProfessorLayout.titleLineHeight /
          AvaliacoesProfessorLayout.titleFontSize,
    );

    if (widget.isMobile) {
      return FutureBuilder<ProfessorEvaluationsOverviewDto>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: AvaliacoesProfessorColors.background,
              padding: const EdgeInsets.symmetric(vertical: 64),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Container(
              color: AvaliacoesProfessorColors.background,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: _ErrorState(
                titleStyle: const TextStyle(
                  color: AvaliacoesProfessorColors.title,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
                message:
                    snapshot.error?.toString() ??
                    'Erro ao carregar avaliações',
                onRetry: _refresh,
                isMobile: true,
              ),
            );
          }

          return _buildMobileContent(snapshot.data ?? _emptyData, config);
        },
      );
    }

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
              const ProfessorMenuNav(selectedIndex: 9),
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
                              'Erro ao carregar avaliações',
                          onRetry: _refresh,
                        );
                      }

                      final data = snapshot.data ?? _emptyData;

                      return _buildDesktopContent(data, titleStyle, config);
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
  const _ProfessorTabs({required this.selectedTab, required this.onChanged, required this.config});

  final AvaliacoesProfessorTab selectedTab;
  final ValueChanged<AvaliacoesProfessorTab> onChanged;
  final TeachingRoleConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          _ProfessorTabButton(
            label: config.roleName,
            selected: selectedTab == AvaliacoesProfessorTab.professor,
            primaryColor: config.primaryColor,
            isOrange: config.roleName == 'Explicador',
            onTap: () => onChanged(AvaliacoesProfessorTab.professor),
          ),
          const SizedBox(width: 28),
          _ProfessorTabButton(
            label: config.avaliacoes.sessionTabLabel,
            selected: selectedTab == AvaliacoesProfessorTab.aulas,
            primaryColor: config.primaryColor,
            isOrange: config.roleName == 'Explicador',
            onTap: () => onChanged(AvaliacoesProfessorTab.aulas),
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
    required this.primaryColor,
    required this.isOrange,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor; 
  final bool isOrange;

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
                    ? (isOrange ? AvaliacoesProfessorColors.summaryGradientTop : primaryColor)
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
                color: selected && !isOrange ? primaryColor : null,
                gradient: selected && isOrange 
                   ? const LinearGradient(colors: [AvaliacoesProfessorColors.summaryGradientTop, AvaliacoesProfessorColors.summaryGradientBottom]) 
                   : null,
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
    this.isMobile = false,
  });

  final TextStyle titleStyle;
  final String message;
  final VoidCallback onRetry;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          Text('Avaliações', style: titleStyle)
        else
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
    required this.primaryColor,
    required this.isOrange,
  });

  final double average;
  final String totalLabel;
  final String label;
  final Color primaryColor;
  final bool isOrange;

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
          color: isOrange ? null : primaryColor, 
          gradient: isOrange
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AvaliacoesProfessorColors.summaryGradientTop,
                  AvaliacoesProfessorColors.summaryGradientBottom,
                ],
              )
            : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 18.042,
              offset: const Offset(0, 12.028),
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
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AvaliacoesProfessorLayout.reviewCardPadding,
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

String _normalizeName(String value, TeachingRoleConfig config) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? config.avaliacoes.reviewerDefaultName : trimmed;
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