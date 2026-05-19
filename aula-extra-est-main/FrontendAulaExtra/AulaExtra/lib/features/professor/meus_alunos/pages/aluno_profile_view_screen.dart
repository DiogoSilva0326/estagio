import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_mobile_page_scaffold.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/disciplina_badge.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlunoProfileViewScreen extends StatelessWidget {
  const AlunoProfileViewScreen({super.key});

  ProfessorAlunoDto? _resolveAluno(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    if (arguments is ProfessorAlunoDto) {
      return arguments;
    }

    if (arguments is Map<String, dynamic>) {
      final aluno = arguments['aluno'];
      if (aluno is ProfessorAlunoDto) {
        return aluno;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final aluno = _resolveAluno(context);
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    if (aluno == null) {
      final fallback = _ProfileUnavailableState(isMobile: isMobile);
      if (isMobile) {
        return ProfessorMobilePageScaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          child: fallback,
        );
      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: PinnedHeaderDelegate(
                height: AppHeader.resolvedHeight(context),
                child: const AppHeader(),
              ),
            ),
            SliverToBoxAdapter(
              child: FullBleedScaledSection(
                child: fallback,
              ),
            ),
            const SliverToBoxAdapter(child: FooterSection()),
          ],
        ),
      );
    }

    if (isMobile) {
      return ProfessorMobilePageScaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        child: _AlunoProfileViewContent(aluno: aluno, isMobile: true),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: AppHeader.resolvedHeight(context),
              child: const AppHeader(),
            ),
          ),
          SliverToBoxAdapter(
            child: FullBleedScaledSection(
              child: _AlunoProfileViewContent(aluno: aluno, isMobile: false),
            ),
          ),
          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }
}

class _AlunoProfileViewContent extends StatelessWidget {
  const _AlunoProfileViewContent({required this.aluno, required this.isMobile});

  final ProfessorAlunoDto aluno;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    final config = TeachingRoleConfig.fromRole(role);

    final isMemberContext = config.studentsLabel.toLowerCase().contains(
      'membros',
    );
    final entityLabel = isMemberContext ? 'Membro' : 'Aluno';
    final interestSubjects = aluno.interestSubjects.isNotEmpty
        ? aluno.interestSubjects
        : aluno.subjects;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                foregroundColor: config.primaryDark,
                backgroundColor: config.primaryLight,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Perfil do $entityLabel',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: MeusAlunosProfessorColors.title,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Detalhes públicos e progresso do ${entityLabel.toLowerCase()} associado.',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF667085),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 18 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: config.borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(16, 24, 40, 0.08),
                offset: Offset(0, 12),
                blurRadius: 26,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Avatar(aluno: aluno),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aluno.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: MeusAlunosProfessorColors.title,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '@${aluno.username}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF667085),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: config.primaryLight,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            entityLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: config.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoPill(
                    label: 'Avaliações submetidas',
                    value: aluno.submittedReviewsTotal.toString(),
                    backgroundColor: config.primaryLight,
                    borderColor: config.borderColor,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Disciplinas de Interesse',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MeusAlunosProfessorColors.title,
                ),
              ),
              const SizedBox(height: 10),
              if (interestSubjects.isEmpty)
                const Text(
                  'Sem disciplinas de interesse associadas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final subject in interestSubjects)
                      DisciplinaBadge(
                        label: subject,
                        color: config.primaryColor,
                        backgroundColor: config.primaryLight,
                        textColor: config.primaryDark,
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              Text(
                'Avaliações Submetidas Por Role',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: MeusAlunosProfessorColors.title,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ReviewCountCard(
                    label: 'Professores',
                    count: aluno.submittedReviewsProfessores,
                    backgroundColor: const Color(0xFFEFF6FF),
                    textColor: const Color(0xFF1D4ED8),
                  ),
                  _ReviewCountCard(
                    label: 'Tutores',
                    count: aluno.submittedReviewsTutores,
                    backgroundColor: const Color(0xFFECFEFF),
                    textColor: const Color(0xFF0E7490),
                  ),
                  _ReviewCountCard(
                    label: 'Psicólogos',
                    count: aluno.submittedReviewsPsicologos,
                    backgroundColor: const Color(0xFFECFDF3),
                    textColor: const Color(0xFF027A48),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Container(
      color: const Color(0xFFF9FAFB),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 32,
        isMobile ? 20 : 34,
        isMobile ? 16 : 32,
        isMobile ? 26 : 44,
      ),
      child: isMobile
          ? body
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: body,
              ),
            ),
    );
  }
}

class _ReviewCountCard extends StatelessWidget {
  const _ReviewCountCard({
    required this.label,
    required this.count,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final int count;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.aluno});

  final ProfessorAlunoDto aluno;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: aluno.avatarUrl.trim().isEmpty
          ? const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 34)
          : Image.network(
              aluno.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  color: Color(0xFF9CA3AF),
                  size: 34,
                );
              },
            ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.value,
    required this.backgroundColor,
    required this.borderColor,
  });

  final String label;
  final String value;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            height: 1.4,
            color: Color(0xFF475467),
          ),
          children: [
            TextSpan(text: '$label: '),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF101828),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileUnavailableState extends StatelessWidget {
  const _ProfileUnavailableState({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9FAFB),
      padding: EdgeInsets.all(isMobile ? 16 : 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4E7EC)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_search_rounded,
                  size: 40,
                  color: Color(0xFF98A2B3),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Não foi possível abrir o perfil.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Volte à listagem e tente novamente a partir do botão Ver perfil.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF667085),
                  ),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
