import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/data/tutors/my_tutors_service.dart';
import 'package:aula_extra/core/data/tutors/dtos/my_tutor_dto.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/models/marcar_aula_professor_args.dart';
import 'package:aula_extra/features/aluno/meus_explicadores/constants/meus_explicadores_constants.dart';
import 'package:aula_extra/features/aluno/meus_explicadores/widgets/tutor_card.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeusExplicadoresContentSection extends StatefulWidget {
  const MeusExplicadoresContentSection({super.key});

  @override
  State<MeusExplicadoresContentSection> createState() => _MeusExplicadoresContentSectionState();
}

class _MeusExplicadoresContentSectionState extends State<MeusExplicadoresContentSection> {
  late final Future<List<MyTutorDto>> _future;

  @override
  void initState() {
    super.initState();
    _future = MyTutorsService().getMyTutors();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final d = dt.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final isStudent = role == Role.student;

    if (!isStudent) return const SizedBox.shrink();

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
                const Text(
                  'Meus Explicadores',
                  style: MeusExplicadoresConstants.titleStyle,
                ),
                const SizedBox(height: MeusExplicadoresConstants.titleSubtitleGap),
                const Text(
                  'Veja seus explicadores preferidos e gerencie suas aulas',
                  style: MeusExplicadoresConstants.subtitleStyle,
                ),
                const SizedBox(height: MeusExplicadoresConstants.afterSubtitleGap),
                FutureBuilder<List<MyTutorDto>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Não foi possível carregar os explicadores',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }

                    final items = snapshot.data ?? const <MyTutorDto>[];
                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Ainda não tens explicadores',
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
                            final subject = (item.lastLessonSubject == null || item.lastLessonSubject!.trim().isEmpty)
                                ? '—'
                                : item.lastLessonSubject!.trim();

                            return TutorCard(
                              name: item.tutorName,
                              subject: subject,
                              subjects: [subject],
                              lastLessonDateText: _formatDate(item.lastLessonStart),
                              rating: item.rating,
                              progress: item.progress,
                              onViewProfileTap: () {
                                Navigator.of(context).pushNamed(
                                  Routes.tutorProfile,
                                  arguments: TutorProfileArgs(
                                    name: item.tutorName,
                                    country: 'Portugal',
                                    rating: item.rating ?? 0,
                                    reviewCount: 84,
                                    description:
                                        'Sou ${item.tutorName}, um explicador apaixonado por ensinar e ajudar alunos a alcançarem os seus objetivos.',
                                    lessonsText: '—',
                                    pricePerHour: 25,
                                    tags: [subject],
                                  ),
                                );
                              },
                              onChatTap: () {},
                              onScheduleTap: () {
                                Navigator.of(context).pushNamed(
                                  Routes.marcarAulaProfessor,
                                  arguments: MarcarAulaProfessorArgs(
                                    tutorName: item.tutorName,
                                    subject: subject,
                                    rating: item.rating ?? 0,
                                    reviewCount: 84,
                                    location: 'Lisboa',
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

// helper rows removed; grid uses `TutorCard` directly.
