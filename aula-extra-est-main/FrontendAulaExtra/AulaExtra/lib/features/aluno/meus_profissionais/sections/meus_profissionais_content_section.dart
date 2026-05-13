import 'package:aula_extra/core/data/complaints/complaints_service.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/data/tutors/my_tutors_service.dart';
import 'package:aula_extra/core/data/tutors/dtos/my_tutor_dto.dart';
import 'package:aula_extra/features/shared/complaints/widgets/related_user_complaint_dialog.dart';
import 'package:aula_extra/features/aluno/chats/models/chat_bootstrap_args.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/models/marcar_aula_professor_args.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/aluno/meus_profissionais/constants/meus_explicadores_constants.dart';
import 'package:aula_extra/features/aluno/meus_profissionais/sections/meus_profissionais_mobile_content_section.dart';
import 'package:aula_extra/features/aluno/meus_profissionais/widgets/tutor_card.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeusProfissionaisContentSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emptyStateTitle;
  final String emptyStateMessage;
  final String findMoreLabel;
  final String targetRole; // 'Explicador', 'Tutor' ou 'Psicólogo'
  final String findMoreRoute;

  const MeusProfissionaisContentSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emptyStateTitle,
    required this.emptyStateMessage,
    required this.findMoreLabel,
    required this.targetRole,
    required this.findMoreRoute,
  });

  @override
  State<MeusProfissionaisContentSection> createState() =>
      _MeusProfissionaisContentSectionState();
}

class _MeusProfissionaisContentSectionState extends State<MeusProfissionaisContentSection> {
  Future<List<MyTutorDto>>? _future;
  final ComplaintsService _complaintsService = ComplaintsService();
  String? _loadError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_future == null) {
      _future = _loadTutors();
    }
  }

  Future<List<MyTutorDto>> _loadTutors() async {
    try {
      _loadError = null;
      return await MyTutorsService().getMyTutors(role: widget.targetRole);
    } catch (error) {
      _loadError = error.toString();
      rethrow;
    }
  }

  void _retryLoad() {
    setState(() {
      _future = _loadTutors();
    });
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final d = dt.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  void _openTutorChat(MyTutorDto tutor) {
    final tutorUserId = tutor.tutorUserId.trim();
    if (tutorUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o chat.')),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      Routes.chats,
      arguments: ChatBootstrapArgs(
        contactUserId: tutorUserId,
        contactName: tutor.tutorName,
        contactUsername: tutor.tutorUsername,
      ),
    );
  }

  Future<void> _showComplaintDialog(MyTutorDto tutor) async {
    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => RelatedUserComplaintDialog(
        targetUserId: tutor.tutorUserId,
        targetName: tutor.tutorName,
        targetRoleLabel: 'do ${widget.targetRole.toLowerCase()}',
        relationshipType: 'professor',
        onSubmit: _complaintsService.createRelatedUserComplaint,
      ),
    );

    if (!mounted || submitted != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reclamação submetida sobre ${tutor.tutorName}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isStudent = role == Role.student;
    final isMobile = MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (!isStudent) return const SizedBox.shrink();

    if (isMobile) {
      return FutureBuilder<List<MyTutorDto>>(
        future: _future,
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <MyTutorDto>[];
          return MeusProfissionaisMobileContentSection( 
            title: widget.title,
            subtitle: widget.subtitle,
            emptyStateTitle: widget.emptyStateTitle,
            emptyStateMessage: widget.emptyStateMessage,
            findMoreLabel: widget.findMoreLabel,
            loading: snapshot.connectionState == ConnectionState.waiting,
            error: snapshot.hasError ? (_loadError ?? 'Não foi possível carregar os dados.') : null,
            tutors: items,
            formatDate: _formatDate,
            onRetry: _retryLoad,
            onViewProfileTap: (item) {
              final subjects = item.subjects.where((v) => v.trim().isNotEmpty).toList();
              final subject = subjects.isNotEmpty ? subjects.first : (item.lastLessonSubject?.trim() ?? '—');

              Navigator.of(context).pushNamed(
                Routes.tutorProfile,
                arguments: TutorProfileArgs(
                  professorId: item.professorId,
                  name: item.tutorName,
                  country: 'Portugal',
                  rating: item.rating ?? 0,
                  reviewCount: item.reviewCount,
                  description: 'Perfil de ${item.tutorName}',
                  lessonsText: '—',
                  pricePerHour: 25,
                  tags: subjects.isNotEmpty ? subjects.take(2).toList() : [subject],
                ),
              );
            },
            onChatTap: _openTutorChat,
            onComplaintTap: (item) => _showComplaintDialog(item),
            onScheduleTap: (item) {
              final subjects = item.subjects.where((v) => v.trim().isNotEmpty).toList();
              final subject = subjects.isNotEmpty ? subjects.first : (item.lastLessonSubject?.trim() ?? '—');

              Navigator.of(context).pushNamed(
                Routes.marcarAulaProfessor,
                arguments: MarcarAulaProfessorArgs(
                  professorId: item.professorId,
                  tutorName: item.tutorName,
                  subject: subject,
                  rating: item.rating ?? 0,
                  reviewCount: item.reviewCount,
                  location: 'Online',
                  pricePerHour: 25,
                ),
              );
            },
            onFindMoreTap: () => Navigator.of(context).pushNamed(widget.findMoreRoute),
          );
        },
      );
    }

    bool _isSessao(String name) {
      final n = name.trim().toLowerCase();
      return n.contains('psicolog') || n.contains('terapia') || n.contains('ansiedade') || 
            n.contains('orientação') || n.contains('tutor') || n.contains('mentoria');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: MeusExplicadoresConstants.horizontalPadding,
        vertical: MeusExplicadoresConstants.verticalPadding,
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
                const SizedBox(height: MeusExplicadoresConstants.topSpacer),
                Text(
                  widget.title,
                  style: MeusExplicadoresConstants.titleStyle,
                ),
                const SizedBox(height: MeusExplicadoresConstants.titleSubtitleGap),
                Text(
                  widget.subtitle,
                  style: MeusExplicadoresConstants.subtitleStyle,
                ),
                const SizedBox(height: MeusExplicadoresConstants.afterSubtitleGap),
                FutureBuilder<List<MyTutorDto>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Não foi possível carregar os dados',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    final items = snapshot.data ?? const <MyTutorDto>[];
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          widget.emptyStateTitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final availableWidth = constraints.maxWidth;
                        const cardWidth = MeusExplicadoresConstants.cardWidth;
                        const spacing = MeusExplicadoresConstants.gridSpacing;
                        final columns = ((availableWidth + spacing) / (cardWidth + spacing)).floor().clamp(1, 3);

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: spacing,
                            mainAxisExtent: MeusExplicadoresConstants.gridMainAxisExtent,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final subjects = item.subjects.where((v) => v.trim().isNotEmpty).toList();
                            final subject = subjects.isNotEmpty ? subjects.first : (item.lastLessonSubject?.trim() ?? '—');

                            return TutorCard(
                              name: item.tutorName,
                              subject: subject,
                              subjects: subjects.isNotEmpty ? subjects : [subject],
                              singularTerm: _isSessao(widget.title) ? 'Sessão' : 'Aula',
                              avatarUrl: item.avatarUrl,
                              lastLessonDateText: _formatDate(item.lastLessonStart),
                              rating: item.rating,
                              progress: item.progress,
                              onViewProfileTap: () {
                                Navigator.of(context).pushNamed(
                                  Routes.tutorProfile,
                                  arguments: TutorProfileArgs(
                                    professorId: item.professorId,
                                    name: item.tutorName,
                                    country: 'Portugal',
                                    rating: item.rating ?? 0,
                                    reviewCount: item.reviewCount,
                                    description: 'Perfil de ${item.tutorName}',
                                    lessonsText: '—',
                                    pricePerHour: 25,
                                    tags: subjects.isNotEmpty ? subjects.take(2).toList() : [subject],
                                  ),
                                );
                              },
                              onChatTap: () => _openTutorChat(item),
                              onComplaintTap: () => _showComplaintDialog(item),
                              onScheduleTap: () {
                                Navigator.of(context).pushNamed(
                                  Routes.marcarAulaProfessor,
                                  arguments: MarcarAulaProfessorArgs(
                                    professorId: item.professorId,
                                    tutorName: item.tutorName,
                                    subject: subject,
                                    rating: item.rating ?? 0,
                                    reviewCount: item.reviewCount,
                                    location: 'Online',
                                    pricePerHour: 25,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
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