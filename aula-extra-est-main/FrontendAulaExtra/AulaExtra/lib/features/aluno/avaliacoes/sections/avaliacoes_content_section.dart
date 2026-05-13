import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/avaliacoes/constants/avaliacoes_constants.dart';
import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/core/data/student_evaluations/dtos/submitted_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_evaluations/student_evaluations_service.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/dtos/submitted_professor_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/student_professor_evaluations_service.dart';
import 'package:aula_extra/features/aluno/avaliacoes/models/avaliacao_review.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliacoes_mobile_cta_card.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliacoes_mobile_intro.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliacoes_mobile_mode_tabs.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliacoes_mobile_review_card.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliacoes_mobile_stat_card.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliacao_review_card.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliar_aula_dialog.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliar_professor_card.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliar_professor_dialog.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliar_ultima_aula_card.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliacoes_stats_row.dart';
import 'package:flutter/material.dart';

enum _AvaliacoesMode { aulas, professores }

class AvaliacoesContentSection extends StatefulWidget {
  const AvaliacoesContentSection({super.key});

  @override
  State<AvaliacoesContentSection> createState() =>
      _AvaliacoesContentSectionState();
}

class _AvaliacoesContentSectionState extends State<AvaliacoesContentSection> {
  final StudentEvaluationsService _service = StudentEvaluationsService();
  final StudentProfessorEvaluationsService _profService =
      StudentProfessorEvaluationsService();

  _AvaliacoesMode _mode = _AvaliacoesMode.aulas;
  late Future<List<SubmittedEvaluationDto>> _submittedLessonsFuture;
  late Future<List<SubmittedProfessorEvaluationDto>> _submittedProfessorsFuture;

  @override
  void initState() {
    super.initState();
    _submittedLessonsFuture = _service.getSubmitted();
    _submittedProfessorsFuture = _profService.getSubmitted();
  }

  void _refreshSubmittedLessons() {
    setState(() {
      _submittedLessonsFuture = _service.getSubmitted();
    });
  }

  void _refreshSubmittedProfessors() {
    setState(() {
      _submittedProfessorsFuture = _profService.getSubmitted();
    });
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final y = local.year.toString();
    return '$d/$m/$y';
  }

  static AvaliacaoReview _toReview(SubmittedEvaluationDto dto) {
    final tutorName =
        (dto.professorName == null || dto.professorName!.trim().isEmpty)
        ? 'Explicador'
        : dto.professorName!.trim();
    final subject = (dto.subject == null || dto.subject!.trim().isEmpty)
        ? '—'
        : dto.subject!.trim();
    final rating = (dto.rating ?? 0).toDouble();
    final comment = (dto.comments == null || dto.comments!.trim().isEmpty)
        ? '—'
        : dto.comments!.trim();
    final dateLabel = _formatDate(
      dto.createdAt ?? dto.lessonEnd ?? dto.lessonStart,
    );

    return AvaliacaoReview(
      tutorName: tutorName,
      subject: subject,
      rating: rating,
      comment: comment,
      dateLabel: dateLabel,
    );
  }

  static AvaliacaoReview _toProfessorReview(
    SubmittedProfessorEvaluationDto dto,
  ) {
    final tutorName = dto.professorName.trim().isEmpty
        ? 'Profissional'
        : dto.professorName.trim();
    final rating = (dto.rating ?? 0).toDouble();
    final comment = (dto.comments == null || dto.comments!.trim().isEmpty)
        ? '—'
        : dto.comments!.trim();
    final dateLabel = _formatDate(dto.createdAt);

    return AvaliacaoReview(
      tutorName: tutorName,
      subject: 'Avaliação de Profisional',
      rating: rating,
      comment: comment,
      dateLabel: dateLabel,
    );
  }

  Future<void> _showLessonEvaluationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const AvaliarAulaDialog(),
    );
    if (result == true) {
      _refreshSubmittedLessons();
    }
  }

  Future<void> _showProfessorEvaluationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const AvaliarProfessorDialog(),
    );
    if (result == true) {
      _refreshSubmittedProfessors();
    }
  }

  Widget _tabs() {
    Widget tab({
      required double width,
      required String text,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        child: SizedBox(
          width: width,
          height: 70.014,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.404,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? CalendarioConstants.activeTabColor
                        : CalendarioConstants.inactiveTabColor,
                    height: 33.607 / 22.404,
                  ),
                ),
              ),
              if (selected)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    height: 2.801,
                    child: ColoredBox(
                      color: CalendarioConstants.activeTabColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CalendarioConstants.dividerColor,
            width: 1.4,
          ),
        ),
      ),
      child: SizedBox(
        height: 71.414,
        child: Row(
          children: [
            tab(
              width: 180,
              text: 'Sessões',
              selected: _mode == _AvaliacoesMode.aulas,
              onTap: () => setState(() => _mode = _AvaliacoesMode.aulas),
            ),
            const SizedBox(width: 22.404),
            tab(
              width: 220,
              text: 'Profissional',
              selected: _mode == _AvaliacoesMode.professores,
              onTap: () => setState(() => _mode = _AvaliacoesMode.professores),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileTabs() {
    return AvaliacoesMobileModeTabs(
      isLessonsSelected: _mode == _AvaliacoesMode.aulas,
      onLessonsTap: () => setState(() => _mode = _AvaliacoesMode.aulas),
      onProfessorTap: () => setState(() => _mode = _AvaliacoesMode.professores),
    );
  }

  Widget _buildMobileStats({required double media, required int realizadas}) {
    return Row(
      children: [
        Expanded(
          child: AvaliacoesMobileStatCard(
            value: media.toStringAsFixed(1),
            label: 'Média das suas avaliações',
            borderColor: const Color(0xFFFFF085),
            valueColor: const Color(0xFFA65F00),
            labelColor: const Color(0xFFA65F00),
            gradient: const LinearGradient(
              begin: Alignment(-0.86, -0.5),
              end: Alignment(0.86, 0.5),
              colors: [Color(0xFFFEFCE8), Color(0xFFFEF9C2)],
            ),
            leading: const Icon(
              Icons.star_rounded,
              size: 26,
              color: Color(0xFFA65F00),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AvaliacoesMobileStatCard(
            value: '$realizadas',
            label: 'Avaliações realizadas',
            borderColor: const Color(0xFFBEDBFF),
            valueColor: const Color(0xFF155DFC),
            labelColor: const Color(0xFF1447E6),
            gradient: const LinearGradient(
              begin: Alignment(-0.86, -0.5),
              end: Alignment(0.86, 0.5),
              colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
            ),
            leading: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF2B7FFF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$realizadas',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCallToAction() {
    if (_mode == _AvaliacoesMode.aulas) {
      return AvaliacoesMobileCtaCard(
        title: 'Tem uma sessão recente para avaliar?',
        subtitle: 'Ajude outros membros compartilhando a sua experiência.',
        buttonLabel: 'Avaliar Última Sessão',
        onTap: _showLessonEvaluationDialog,
      );
    }

    return AvaliacoesMobileCtaCard(
      title: 'Quer avaliar um profissional?',
      subtitle: 'Só é possível avaliar uma vez por profissional.',
      buttonLabel: 'Avaliar Profissional',
      onTap: _showProfessorEvaluationDialog,
    );
  }

  Widget _buildReviewsList(
    List<AvaliacaoReview> reviews, {
    required bool isMobile,
  }) {
    if (reviews.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: isMobile
            ? BoxDecoration(
                color: AvaliacoesConstants.mobileSurfaceColor,
                borderRadius: BorderRadius.circular(
                  AvaliacoesConstants.mobileCardRadius,
                ),
                border: Border.all(
                  color: AvaliacoesConstants.mobileBorderColor,
                ),
              )
            : null,
        child: Text(
          'Ainda não tem avaliações submetidas.',
          style: isMobile ? AvaliacoesConstants.mobileBodyStyle : null,
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < reviews.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == reviews.length - 1
                  ? 0
                  : isMobile
                  ? 12
                  : AvaliacoesConstants.gapSection,
            ),
            child: isMobile
                ? AvaliacoesMobileReviewCard(review: reviews[index])
                : AvaliacaoReviewCard(review: reviews[index]),
          ),
      ],
    );
  }

  Widget _buildMobileView({
    required double media,
    required int realizadas,
    required List<AvaliacaoReview> reviews,
    required String? error,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AvaliacoesConstants.mobileHorizontalPadding,
        vertical: AvaliacoesConstants.mobileVerticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AvaliacoesMobileIntro(
            title: 'Avaliações',
            subtitle:
                'Escolhe uma área ou disciplina específica para encontrar as tuas avaliações.',
          ),
          const SizedBox(height: 14),
          _buildMobileStats(media: media, realizadas: realizadas),
          const SizedBox(height: 14),
          _buildMobileCallToAction(),
          const SizedBox(height: 14),
          _mobileTabs(),
          const SizedBox(height: 14),
          const Text(
            'Suas Avaliações',
            style: AvaliacoesConstants.mobileSectionTitleStyle,
          ),
          const SizedBox(height: 12),
          if (error != null)
            Text(
              error,
              style: AvaliacoesConstants.mobileBodyStyle.copyWith(
                color: const Color(0xFFB42318),
              ),
            )
          else
            _buildReviewsList(reviews, isMobile: true),
        ],
      ),
    );
  }

  Widget _buildDesktopView({
    required double media,
    required int realizadas,
    required List<AvaliacaoReview> reviews,
    required String? error,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AvaliacoesStatsRow(media: media, realizadas: realizadas),
        const SizedBox(height: AvaliacoesConstants.gapAfterStats),
        if (_mode == _AvaliacoesMode.aulas)
          AvaliarUltimaAulaCard(onSubmitted: _refreshSubmittedLessons)
        else
          AvaliarProfessorCard(onSubmitted: _refreshSubmittedProfessors),
        const SizedBox(height: AvaliacoesConstants.gapLarge),
        _tabs(),
        const SizedBox(height: AvaliacoesConstants.gapSection),
        if (error != null)
          Text(error, style: const TextStyle(color: Colors.red))
        else ...[
          const Text(
            'Suas Avaliações',
            style: AvaliacoesConstants.sectionTitleStyle,
          ),
          const SizedBox(height: AvaliacoesConstants.gapSection),
          _buildReviewsList(reviews, isMobile: false),
        ],
      ],
    );
  }

  Widget _buildLessonsContent(bool isMobile) {
    return FutureBuilder<List<SubmittedEvaluationDto>>(
      future: _submittedLessonsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final reviews = (snapshot.data ?? const <SubmittedEvaluationDto>[])
            .map(_toReview)
            .toList(growable: false);
        final count = reviews.length;
        final avg = count == 0
            ? 0.0
            : reviews.map((review) => review.rating).reduce((a, b) => a + b) /
                  count;
        final error = snapshot.hasError
            ? (snapshot.error?.toString() ?? 'Erro ao carregar avaliações')
            : null;

        return isMobile
            ? _buildMobileView(
                media: avg,
                realizadas: count,
                reviews: reviews,
                error: error,
              )
            : _buildDesktopView(
                media: avg,
                realizadas: count,
                reviews: reviews,
                error: error,
              );
      },
    );
  }

  Widget _buildProfessorsContent(bool isMobile) {
    return FutureBuilder<List<SubmittedProfessorEvaluationDto>>(
      future: _submittedProfessorsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final reviews =
            (snapshot.data ?? const <SubmittedProfessorEvaluationDto>[])
                .map(_toProfessorReview)
                .toList(growable: false);
        final count = reviews.length;
        final avg = count == 0
            ? 0.0
            : reviews.map((review) => review.rating).reduce((a, b) => a + b) /
                  count;
        final error = snapshot.hasError
            ? (snapshot.error?.toString() ?? 'Erro ao carregar avaliações')
            : null;

        return isMobile
            ? _buildMobileView(
                media: avg,
                realizadas: count,
                reviews: reviews,
                error: error,
              )
            : _buildDesktopView(
                media: avg,
                realizadas: count,
                reviews: reviews,
                error: error,
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (isMobile) {
      return _mode == _AvaliacoesMode.aulas
          ? _buildLessonsContent(true)
          : _buildProfessorsContent(true);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AvaliacoesConstants.horizontalPadding,
        vertical: AvaliacoesConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Avaliações', style: AvaliacoesConstants.titleStyle),
                const SizedBox(height: AvaliacoesConstants.gapSmall),
                const Text(
                  'Avalie os seus apoios e ajude outros estudantes',
                  style: AvaliacoesConstants.subtitleStyle,
                ),
                const SizedBox(height: AvaliacoesConstants.gapLarge),
                _mode == _AvaliacoesMode.aulas
                    ? _buildLessonsContent(false)
                    : _buildProfessorsContent(false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
