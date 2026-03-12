import 'package:aula_extra/features/tutor_profile_view/sections/section_container.dart';
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
  });

  final String description;

  @override
  Widget build(BuildContext context) {
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
          const SectionContainer(
            title: 'Idiomas que falo',
            child: Row(
              children: [
                Expanded(child: Pill(text: 'Inglês (Nativo)', dense: true)),
                SizedBox(width: 15.319),
                Expanded(child: Pill(text: 'Português (Avançado)', dense: true)),
                SizedBox(width: 15.319),
                Expanded(child: Pill(text: 'Espanhol (Intermédio)', dense: true)),
              ],
            ),
          ),
          const SizedBox(height: 40.851),
          const SectionContainer(
            title: 'Disciplinas',
            child: Row(
              children: [
                Expanded(child: GradientTag(text: 'Matemática')),
                SizedBox(width: 15.319),
                Expanded(child: GradientTag(text: 'Ciências')),
                SizedBox(width: 15.319),
                Expanded(child: GradientTag(text: 'Inglês')),
              ],
            ),
          ),
          const SizedBox(height: 40.851),
          const SectionContainer(
            title: 'Formação',
            child: Column(
              children: [
                BulletRow(
                  icon: Icons.school_outlined,
                  text: 'Mestrado em Educação - Universidade de Cambridge',
                ),
                SizedBox(height: 10.213),
                BulletRow(
                  icon: Icons.menu_book_outlined,
                  text: 'Licenciatura em Línguas e Literaturas Modernas - Universidade de Oxford',
                ),
                SizedBox(height: 10.213),
                BulletRow(
                  icon: Icons.verified_outlined,
                  text: 'Certificação CELTA - Cambridge English',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40.851),
          const SectionContainer(
            title: 'Horários Disponíveis',
            leadingIcon: Icons.calendar_month_outlined,
            child: ScheduleGrid(),
          ),
          const SizedBox(height: 40.851),
          const SectionContainer(
            title: 'Avaliações',
            child: ReviewsList(),
          ),
        ],
      ),
    );
  }
}
