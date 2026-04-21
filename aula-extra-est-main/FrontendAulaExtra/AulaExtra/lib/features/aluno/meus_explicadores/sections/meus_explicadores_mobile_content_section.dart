import 'package:aula_extra/core/data/tutors/dtos/my_tutor_dto.dart';
import 'package:aula_extra/features/aluno/meus_explicadores/constants/meus_explicadores_mobile_layout.dart';
import 'package:aula_extra/features/aluno/meus_explicadores/widgets/meus_explicadores_mobile_tutor_card.dart';
import 'package:flutter/material.dart';

class MeusExplicadoresMobileContentSection extends StatelessWidget {
  const MeusExplicadoresMobileContentSection({
    super.key,
    required this.loading,
    required this.error,
    required this.tutors,
    required this.formatDate,
    required this.onRetry,
    required this.onViewProfileTap,
    required this.onChatTap,
    required this.onComplaintTap,
    required this.onScheduleTap,
    required this.onFindMoreTap,
  });

  final bool loading;
  final String? error;
  final List<MyTutorDto> tutors;
  final String Function(DateTime? date) formatDate;
  final VoidCallback onRetry;
  final void Function(MyTutorDto tutor) onViewProfileTap;
  final void Function(MyTutorDto tutor) onChatTap;
  final void Function(MyTutorDto tutor) onComplaintTap;
  final void Function(MyTutorDto tutor) onScheduleTap;
  final VoidCallback onFindMoreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MeusExplicadoresMobileLayout.pageBackground,
      padding: const EdgeInsets.fromLTRB(
        MeusExplicadoresMobileLayout.horizontalPadding,
        MeusExplicadoresMobileLayout.topPadding,
        MeusExplicadoresMobileLayout.horizontalPadding,
        32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Meus Explicadores',
            style: TextStyle(
              fontSize: 34,
              height: 1.08,
              fontWeight: FontWeight.w700,
              color: MeusExplicadoresMobileLayout.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Veja os seus explicadores preferidos e gerencie as suas aulas.',
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: MeusExplicadoresMobileLayout.textSecondary,
            ),
          ),
          const SizedBox(height: MeusExplicadoresMobileLayout.sectionSpacing),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error != null)
            _StateCard(
              title: 'Não foi possível carregar os explicadores',
              message: error!,
              actionLabel: 'Tentar novamente',
              onAction: onRetry,
            )
          else if (tutors.isEmpty)
            _StateCard(
              title: 'Ainda não tens explicadores',
              message:
                  'Explora mais explicadores e começa a construir a tua rede de apoio ao estudo.',
              actionLabel: 'Encontrar explicadores',
              onAction: onFindMoreTap,
            )
          else ...[
            Row(
              children: [
                Text(
                  '${tutors.length} explicador${tutors.length == 1 ? '' : 'es'}',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: MeusExplicadoresMobileLayout.textPrimary,
                  ),
                ),
                const Spacer(),
                // const Text(
                //   'Deslize lateralmente',
                //   style: TextStyle(
                //     fontSize: 13,
                //     height: 1.35,
                //     fontWeight: FontWeight.w500,
                //     color: MeusExplicadoresMobileLayout.textMuted,
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 445,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: tutors.length,
                separatorBuilder: (_, _) => const SizedBox(
                  width: MeusExplicadoresMobileLayout.cardSpacing,
                ),
                itemBuilder: (context, index) {
                  final tutor = tutors[index];
                  final subjects = tutor.subjects
                      .where((value) => value.trim().isNotEmpty)
                      .map((value) => value.trim())
                      .toList(growable: false);
                  final subject = subjects.isNotEmpty
                      ? subjects.first
                      : ((tutor.lastLessonSubject == null ||
                                tutor.lastLessonSubject!.trim().isEmpty)
                            ? '—'
                            : tutor.lastLessonSubject!.trim());
                  final cardSubjects = subjects.isNotEmpty
                      ? subjects
                      : [subject];

                  return MeusExplicadoresMobileTutorCard(
                    tutor: tutor,
                    primarySubject: subject,
                    subjects: cardSubjects,
                    lastLessonDateText: formatDate(tutor.lastLessonStart),
                    onViewProfileTap: () => onViewProfileTap(tutor),
                    onChatTap: () => onChatTap(tutor),
                    onComplaintTap: () => onComplaintTap(tutor),
                    onScheduleTap: () => onScheduleTap(tutor),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      MeusExplicadoresMobileLayout.accentOrange,
                      MeusExplicadoresMobileLayout.accentPink,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextButton(
                  onPressed: onFindMoreTap,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Encontrar mais explicadores',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              height: 1.3,
              fontWeight: FontWeight.w700,
              color: MeusExplicadoresMobileLayout.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: MeusExplicadoresMobileLayout.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onAction,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              side: const BorderSide(color: Color(0xFFD1D5DC)),
              foregroundColor: MeusExplicadoresMobileLayout.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
