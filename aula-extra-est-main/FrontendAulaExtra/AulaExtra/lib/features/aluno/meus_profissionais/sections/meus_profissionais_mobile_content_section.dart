import 'package:aula_extra/core/data/tutors/dtos/my_tutor_dto.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';
import 'package:aula_extra/core/providers/user_provider.dart' show Role;
import 'package:aula_extra/features/aluno/meus_profissionais/constants/meus_explicadores_mobile_layout.dart';
import 'package:aula_extra/features/aluno/meus_profissionais/widgets/meus_explicadores_mobile_tutor_card.dart';
import 'package:aula_extra/routes/routes.dart'; // <-- IMPORTANTE: Adicionado para aceder às rotas
import 'package:flutter/material.dart';

class MeusProfissionaisMobileContentSection extends StatelessWidget {
  const MeusProfissionaisMobileContentSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emptyStateTitle,
    required this.emptyStateMessage,
    required this.findMoreLabel,
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

  final String title;
  final String subtitle;
  final String emptyStateTitle;
  final String emptyStateMessage;
  final String findMoreLabel;

  bool _isSessao(String name) {
    final n = name.trim().toLowerCase();
    return n.contains('psicolog') || n.contains('terapia') || n.contains('ansiedade') || 
           n.contains('orientação') || n.contains('tutor') || n.contains('mentoria');
  }

  TeachingRoleConfig _resolveRoleConfig() {
    final normalizedTitle = title.trim().toLowerCase();
    if (normalizedTitle.contains('psic')) {
      return TeachingRoleConfig.fromRole(Role.psychologist);
    }
    if (normalizedTitle.contains('tutor')) {
      return TeachingRoleConfig.fromRole(Role.tutor);
    }
    return TeachingRoleConfig.fromRole(Role.teacher);
  }

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

  // Cria as abas de navegação (Chips)
  Widget _buildTab(BuildContext context, String label, String route, bool isSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        if (!isSelected) {
          Navigator.of(context).pushReplacementNamed(route);
        }
      },
      selectedColor: const Color(0xFFFFF7ED),
      side: BorderSide(
        color: isSelected ? const Color(0xFFFC9039) : const Color(0xFFD1D5DC),
      ),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFFFC9039) : const Color(0xFF6B7280),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleConfig = _resolveRoleConfig();

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
          Text(
            title, 
            style: const TextStyle(
              fontSize: 34,
              height: 1.08,
              fontWeight: FontWeight.w700,
              color: MeusExplicadoresMobileLayout.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: MeusExplicadoresMobileLayout.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab(context, 'Explicadores', Routes.meusExplicadores, title == 'Meus Apoios'),
                const SizedBox(width: 8),
                _buildTab(context, 'Tutores', Routes.meusTutores, title == 'Meus Tutores'),
                const SizedBox(width: 8),
                _buildTab(context, 'Psicólogos', Routes.meusPsicologos, title == 'Meus Psicólogos'),
              ],
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
              title: 'Não foi possível carregar os dados',
              message: error!,
              actionLabel: 'Tentar novamente',
              onAction: onRetry,
            )
          else if (tutors.isEmpty)
            _StateCard(
              title: emptyStateTitle,
              message: emptyStateMessage,
              actionLabel: findMoreLabel, 
              onAction: onFindMoreTap,
            )
          else ...[
            Row(
              children: [
                Text(
                  '${tutors.length} profissional${tutors.length == 1 ? '' : 'ais'}',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: MeusExplicadoresMobileLayout.textPrimary,
                  ),
                ),
                const Spacer(),
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
                    roleConfig: roleConfig,
                    primarySubject: subject,
                    subjects: cardSubjects,
                    lastLessonDateText: formatDate(tutor.lastLessonStart),
                    singularTerm: _isSessao(title) ? 'Sessão' : 'Aula', 
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
                  child: Text(
                    findMoreLabel,
                    style: const TextStyle(
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