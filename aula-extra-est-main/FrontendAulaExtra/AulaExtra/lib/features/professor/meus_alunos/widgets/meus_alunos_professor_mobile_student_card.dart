import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_colors.dart';
import 'package:aula_extra/features/professor/meus_alunos/constants/meus_alunos_professor_layout.dart';
import 'package:aula_extra/features/professor/meus_alunos/widgets/progresso_bar.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MeusAlunosProfessorMobileStudentCard extends StatelessWidget {
  const MeusAlunosProfessorMobileStudentCard({
    super.key,
    required this.aluno,
    required this.onProfileTap,
    required this.onChatTap,
    required this.onFilesTap,
    this.onComplaintTap,
  });

  final ProfessorAlunoDto aluno;
  final VoidCallback onProfileTap;
  final VoidCallback onChatTap;
  final VoidCallback onFilesTap;
  final VoidCallback? onComplaintTap;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    final primaryColor = config.primaryColor;

    final progressPercent = (aluno.progress * 100).round().clamp(0, 100);
    final uniqueSubjects = aluno.subjects
        .map((subject) => subject.trim())
        .where((subject) => subject.isNotEmpty)
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        MeusAlunosProfessorLayout.mobileCardPadding,
      ),
      decoration: BoxDecoration(
        color: MeusAlunosProfessorColors.mobileSurface,
        borderRadius: BorderRadius.circular(
          MeusAlunosProfessorLayout.mobileCardRadius,
        ),
        border: Border.all(color: MeusAlunosProfessorColors.mobileBorder),
        boxShadow: MeusAlunosProfessorColors.mobileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(aluno: aluno),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aluno.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: MeusAlunosProfessorColors.title,
                        height: 24 / 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${aluno.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: MeusAlunosProfessorColors.mobileMutedText,
                        height: 18 / 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (onComplaintTap != null)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF9CA3AF)),
                  onSelected: (value) {
                    if (value == 'report') {
                      onComplaintTap!();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text(
                        'Submeter reclamação',
                        style: TextStyle(color: MeusAlunosProfessorColors.danger),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (uniqueSubjects.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final subject in uniqueSubjects)
                  _SubjectChip(label: subject, color: primaryColor), 
              ],
            ),
          if (uniqueSubjects.isNotEmpty) const SizedBox(height: 16),
          
          _MetaRow(label: config.alunoCard.lastSessionLabel, value: aluno.lastLessonDate),
          
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Progresso',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: MeusAlunosProfessorColors.mobileMutedText,
                  height: 20 / 14,
                ),
              ),
              const Spacer(),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: MeusAlunosProfessorColors.title,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressoBar(
            value: aluno.progress,
            color: primaryColor, 
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PrimaryActionButton(
                  label: 'Ver perfil',
                  icon: Icons.person_outline_rounded,
                  color: primaryColor,
                  onTap: onProfileTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PrimaryActionButton(
                  label: 'Chat',
                  icon: Icons.chat_bubble_outline_rounded,
                  color: primaryColor, 
                  onTap: onChatTap,
                ),
              ),
              const SizedBox(width: 10),
              _IconActionButton(
                icon: Icons.description_outlined,
                color: primaryColor, 
                onTap: onFilesTap,
              ),
            ],
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
      width: MeusAlunosProfessorLayout.mobileAvatarSize,
      height: MeusAlunosProfessorLayout.mobileAvatarSize,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: aluno.avatarUrl.trim().isEmpty
          ? const Icon(Icons.person, color: Color(0xFF9CA3AF), size: 28)
          : Image.network(
              aluno.avatarUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.person,
                  color: Color(0xFF9CA3AF),
                  size: 28,
                );
              },
            ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          height: 16 / 12,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label:', 
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: MeusAlunosProfessorColors.mobileMutedText,
            height: 20 / 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: MeusAlunosProfessorColors.title,
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MeusAlunosProfessorLayout.mobileActionButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color, 
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MeusAlunosProfessorLayout.mobileActionButtonHeight,
      height: MeusAlunosProfessorLayout.mobileActionButtonHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: color),
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}