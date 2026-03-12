import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/features/aluno/avaliacoes/constants/avaliacoes_constants.dart';
import 'package:aula_extra/features/aluno/calendario/constants/calendario_constants.dart';
import 'package:aula_extra/core/data/student_evaluations/dtos/submitted_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_evaluations/student_evaluations_service.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/dtos/submitted_professor_evaluation_dto.dart';
import 'package:aula_extra/core/data/student_professor_evaluations/student_professor_evaluations_service.dart';
import 'package:aula_extra/features/aluno/avaliacoes/models/avaliacao_review.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliacao_review_card.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliar_professor_card.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliar_ultima_aula_card.dart';
import 'package:aula_extra/features/aluno/avaliacoes/widgets/avaliacoes_stats_row.dart';
import 'package:flutter/material.dart';

enum _AvaliacoesMode {
  aulas,
  professores,
}

class AvaliacoesContentSection extends StatefulWidget {
  const AvaliacoesContentSection({super.key});

  @override
  State<AvaliacoesContentSection> createState() => _AvaliacoesContentSectionState();
}

class _AvaliacoesContentSectionState extends State<AvaliacoesContentSection> {
  final StudentEvaluationsService _service = StudentEvaluationsService();
  final StudentProfessorEvaluationsService _profService = StudentProfessorEvaluationsService();

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
    final tutorName = (dto.professorName == null || dto.professorName!.trim().isEmpty)
        ? 'Explicador'
        : dto.professorName!.trim();
    final subject = (dto.subject == null || dto.subject!.trim().isEmpty) ? '—' : dto.subject!.trim();
    final rating = (dto.rating ?? 0).toDouble();
    final comment = (dto.comments == null || dto.comments!.trim().isEmpty) ? '—' : dto.comments!.trim();
    final dateLabel = _formatDate(dto.createdAt ?? dto.lessonEnd ?? dto.lessonStart);

    return AvaliacaoReview(
      tutorName: tutorName,
      subject: subject,
      rating: rating,
      comment: comment,
      dateLabel: dateLabel,
    );
  }

  static AvaliacaoReview _toProfessorReview(SubmittedProfessorEvaluationDto dto) {
    final tutorName = dto.professorName.trim().isEmpty ? 'Professor' : dto.professorName.trim();
    final rating = (dto.rating ?? 0).toDouble();
    final comment = (dto.comments == null || dto.comments!.trim().isEmpty) ? '—' : dto.comments!.trim();
    final dateLabel = _formatDate(dto.createdAt);

    return AvaliacaoReview(
      tutorName: tutorName,
      subject: 'Avaliação de Professor',
      rating: rating,
      comment: comment,
      dateLabel: dateLabel,
    );
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
                    color: selected ? CalendarioConstants.activeTabColor : CalendarioConstants.inactiveTabColor,
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
                    child: ColoredBox(color: CalendarioConstants.activeTabColor),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CalendarioConstants.dividerColor, width: 1.4)),
      ),
      child: SizedBox(
        height: 71.414,
        child: Row(
          children: [
            tab(
              width: 180,
              text: 'Aulas',
              selected: _mode == _AvaliacoesMode.aulas,
              onTap: () => setState(() => _mode = _AvaliacoesMode.aulas),
            ),
            const SizedBox(width: 22.404),
            tab(
              width: 220,
              text: 'Professor',
              selected: _mode == _AvaliacoesMode.professores,
              onTap: () => setState(() => _mode = _AvaliacoesMode.professores),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AvaliacoesConstants.horizontalPadding,
        vertical: AvaliacoesConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(selectedIndex: 7),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avaliações',
                  style: AvaliacoesConstants.titleStyle,
                ),
                const SizedBox(height: AvaliacoesConstants.gapSmall),
                const Text(
                  'Avalie seus explicadores e ajude outros estudantes',
                  style: AvaliacoesConstants.subtitleStyle,
                ),
                const SizedBox(height: AvaliacoesConstants.gapLarge),
                if (_mode == _AvaliacoesMode.aulas)
                  FutureBuilder<List<SubmittedEvaluationDto>>(
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

                      if (snapshot.hasError) {
                        final msg = snapshot.error?.toString() ?? 'Erro ao carregar avaliações';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AvaliacoesStatsRow(media: 0, realizadas: 0),
                            const SizedBox(height: AvaliacoesConstants.gapAfterStats),
                            AvaliarUltimaAulaCard(onSubmitted: _refreshSubmittedLessons),
                            const SizedBox(height: AvaliacoesConstants.gapLarge),
                            _tabs(),
                            const SizedBox(height: AvaliacoesConstants.gapSection),
                            Text(
                              msg,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        );
                      }

                      final items = snapshot.data ?? const <SubmittedEvaluationDto>[];
                      final reviews = items.map(_toReview).toList(growable: false);
                      final count = reviews.length;
                      final avg = count == 0 ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / count;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvaliacoesStatsRow(media: avg, realizadas: count),
                          const SizedBox(height: AvaliacoesConstants.gapAfterStats),
                          AvaliarUltimaAulaCard(onSubmitted: _refreshSubmittedLessons),
                          const SizedBox(height: AvaliacoesConstants.gapLarge),
                          _tabs(),
                          const SizedBox(height: AvaliacoesConstants.gapSection),
                          const Text(
                            'Suas Avaliações',
                            style: AvaliacoesConstants.sectionTitleStyle,
                          ),
                          const SizedBox(height: AvaliacoesConstants.gapSection),
                          if (reviews.isEmpty)
                            const Text('Ainda não tem avaliações submetidas.')
                          else
                            ...List.generate(reviews.length, (index) {
                              final review = reviews[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == reviews.length - 1 ? 0 : AvaliacoesConstants.gapSection,
                                ),
                                child: AvaliacaoReviewCard(review: review),
                              );
                            }),
                        ],
                      );
                    },
                  )
                else
                  FutureBuilder<List<SubmittedProfessorEvaluationDto>>(
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

                      if (snapshot.hasError) {
                        final msg = snapshot.error?.toString() ?? 'Erro ao carregar avaliações';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AvaliacoesStatsRow(media: 0, realizadas: 0),
                            const SizedBox(height: AvaliacoesConstants.gapAfterStats),
                            AvaliarProfessorCard(onSubmitted: _refreshSubmittedProfessors),
                            const SizedBox(height: AvaliacoesConstants.gapLarge),
                            _tabs(),
                            const SizedBox(height: AvaliacoesConstants.gapSection),
                            Text(
                              msg,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        );
                      }

                      final items = snapshot.data ?? const <SubmittedProfessorEvaluationDto>[];
                      final reviews = items.map(_toProfessorReview).toList(growable: false);
                      final count = reviews.length;
                      final avg = count == 0 ? 0.0 : reviews.map((r) => r.rating).reduce((a, b) => a + b) / count;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AvaliacoesStatsRow(media: avg, realizadas: count),
                          const SizedBox(height: AvaliacoesConstants.gapAfterStats),
                          AvaliarProfessorCard(onSubmitted: _refreshSubmittedProfessors),
                          const SizedBox(height: AvaliacoesConstants.gapLarge),
                          _tabs(),
                          const SizedBox(height: AvaliacoesConstants.gapSection),
                          const Text(
                            'Suas Avaliações',
                            style: AvaliacoesConstants.sectionTitleStyle,
                          ),
                          const SizedBox(height: AvaliacoesConstants.gapSection),
                          if (reviews.isEmpty)
                            const Text('Ainda não tem avaliações submetidas.')
                          else
                            ...List.generate(reviews.length, (index) {
                              final review = reviews[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index == reviews.length - 1 ? 0 : AvaliacoesConstants.gapSection,
                                ),
                                child: AvaliacaoReviewCard(review: review),
                              );
                            }),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
