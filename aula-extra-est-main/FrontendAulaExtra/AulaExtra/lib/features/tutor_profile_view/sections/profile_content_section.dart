import 'package:aula_extra/features/tutor_profile_view/sections/section_container.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_certificate_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_language_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/public_professor_profile_dto.dart';
import 'package:aula_extra/features/tutor_profile_view/widgets/bullet_row.dart';
import 'package:aula_extra/features/tutor_profile_view/widgets/gradient_tag.dart';
import 'package:aula_extra/features/tutor_profile_view/widgets/pill.dart';
import 'package:aula_extra/features/tutor_profile_view/widgets/reviews_list.dart';
import 'package:aula_extra/features/tutor_profile_view/widgets/schedule_grid.dart';
import 'package:flutter/material.dart';

class ProfileContentSection extends StatelessWidget {
  const ProfileContentSection({
    super.key,
    required this.description,
    this.currentSchool,
    this.yearsExperience,
    this.website,
    required this.availability,
    required this.languages,
    required this.disciplinas,
    required this.certificates,
    required this.reviews,
  });

  final String description;
  final String? currentSchool;
  final int? yearsExperience;
  final String? website;
  final List<PublicProfessorAvailabilityDto> availability;
  final List<ProfessorLanguageDto> languages;
  final List<DisciplinaDto> disciplinas;
  final List<ProfessorCertificateDto> certificates;
  final List<PublicProfessorReviewDto> reviews;

  String? _certificateTitle(ProfessorCertificateDto certificate) {
    final explicitName = certificate.name?.trim();
    if (explicitName != null && explicitName.isNotEmpty) return explicitName;

    final rawFileName = certificate.fileUrl?.trim();
    if (rawFileName == null || rawFileName.isEmpty) return null;

    final normalized = rawFileName.split('/').last.trim();
    if (normalized.isEmpty) return null;

    final extensionIndex = normalized.lastIndexOf('.');
    final withoutExtension = extensionIndex > 0
        ? normalized.substring(0, extensionIndex)
        : normalized;

    return withoutExtension.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  }

  List<_FormationItem> _buildFormationItems() {
    final items = <_FormationItem>[];

    if (currentSchool?.trim().isNotEmpty == true) {
      items.add(
        _FormationItem(
          icon: Icons.school_outlined,
          text: currentSchool!.trim(),
        ),
      );
    }

    for (var index = 0; index < certificates.length; index++) {
      final certificate = certificates[index];
      final title = _certificateTitle(certificate) ?? 'Certificado submetido';
      final description = certificate.description?.trim();
      final text = description != null && description.isNotEmpty
          ? '$title - $description'
          : title;

      items.add(
        _FormationItem(
          icon: switch (index % 3) {
            0 => Icons.school_outlined,
            1 => Icons.menu_book_outlined,
            _ => Icons.verified_outlined,
          },
          text: text,
        ),
      );
    }

    if (items.isEmpty && yearsExperience != null) {
      items.add(
        _FormationItem(
          icon: Icons.workspace_premium_outlined,
          text: '$yearsExperience anos de experiência',
        ),
      );
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final formationItems = _buildFormationItems();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.638, vertical: 30.638),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionContainer(
            title: 'Sobre mim',
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 20.426,
                height: 33.191 / 20.426,
                color: Color(0xFF364153),
              ),
            ),
          ),
          const SizedBox(height: 40.851),
          SectionContainer(
            title: 'Idiomas que falo',
            child: languages.isEmpty
                ? const _EmptyStateText(
                    'Este professor ainda não indicou idiomas no perfil.',
                  )
                : Wrap(
                    spacing: 15.319,
                    runSpacing: 15.319,
                    children: [
                      for (final language in languages)
                        SizedBox(
                          width: 431,
                          child: Pill(
                            text:
                                language.proficiencyLevel?.trim().isNotEmpty ==
                                    true
                                ? '${language.nome} (${language.proficiencyLevel!.trim()})'
                                : language.nome,
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 40.851),
          SectionContainer(
            title: 'Disciplinas',
            child: disciplinas.isEmpty
                ? const _EmptyStateText(
                    'Este professor ainda não indicou disciplinas no perfil.',
                  )
                : Wrap(
                    spacing: 15.319,
                    runSpacing: 15.319,
                    children: [
                      for (final disciplina in disciplinas)
                        SizedBox(
                          width: 431,
                          child: GradientTag(text: disciplina.nome),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 40.851),
          SectionContainer(
            title: 'Formação',
            child: formationItems.isEmpty
                ? const _EmptyStateText(
                    'Este professor ainda não indicou formação ou certificações.',
                  )
                : Column(
                    children: [
                      for (
                        var index = 0;
                        index < formationItems.length;
                        index++
                      ) ...[
                        BulletRow(
                          icon: formationItems[index].icon,
                          text: formationItems[index].text,
                        ),
                        if (index < formationItems.length - 1)
                          const SizedBox(height: 10.213),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 40.851),
          SectionContainer(
            title: 'Horários Disponíveis',
            leadingIcon: Icons.calendar_month_outlined,
            child: ScheduleGrid(availability: availability),
          ),
          const SizedBox(height: 40.851),
          SectionContainer(
            title: 'Avaliações',
            child: ReviewsList(reviews: reviews),
          ),
        ],
      ),
    );
  }
}

class _FormationItem {
  const _FormationItem({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

class _EmptyStateText extends StatelessWidget {
  const _EmptyStateText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        height: 1.6,
        color: Color(0xFF6B7280),
      ),
    );
  }
}
