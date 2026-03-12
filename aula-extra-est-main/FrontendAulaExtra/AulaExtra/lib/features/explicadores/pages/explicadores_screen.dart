import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/components/header/variants/header_aluno.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/explicadores/sections/explicadores_hero_section.dart';
import 'package:aula_extra/features/explicadores/sections/filters_sidebar_section.dart';
import 'package:aula_extra/features/explicadores/sections/main_content_header_section.dart';
import 'package:aula_extra/features/explicadores/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/explicadores/widgets/tutor_card.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class ExplicadoresScreen extends StatefulWidget {
  const ExplicadoresScreen({super.key});

  @override
  State<ExplicadoresScreen> createState() => _ExplicadoresScreenState();
}

class _ExplicadoresScreenState extends State<ExplicadoresScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PrimaryScrollController(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: PinnedHeaderDelegate(
                height: AppHeader.height,
                child: AppHeader(
                  headerAlunoActiveItem: HeaderAlunoItem.maisExplicadores,
                  onRegisterTap: () => Navigator.of(context).pushNamed(Routes.registerStudent),
                  onLoginTap: () => Navigator.of(context).pushNamed(Routes.login),
                  onLogoTap: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.home, (route) => false),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                        ),
                      ),
                      child: FullBleedScaledSection(child: ExplicadoresHeroSection()),
                    ),
                  ),
                  const ColoredBox(
                    color: Color(0xFFF9F9F9),
                    child: SizedBox(
                      width: double.infinity,
                      child: FullBleedScaledSection(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: _MainArea(),
                        ),
                      ),
                    ),
                  ),
                  const ColoredBox(
                    color: Color(0xFFF9F9F9),
                    child: FooterSection(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainArea extends StatelessWidget {
  const _MainArea();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.85),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FiltersSidebarSection(),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MainContentHeaderSection(),
                const SizedBox(height: 30),
                const _TutorsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorData {
  const _TutorData({
    required this.name,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.lessonsText,
    required this.pricePerHour,
    required this.tags,
  });

  final String name;
  final String country;
  final double rating;
  final int reviewCount;
  final String description;
  final String lessonsText;
  final int pricePerHour;
  final List<String> tags;
}

class _TutorsSection extends StatefulWidget {
  const _TutorsSection();

  @override
  State<_TutorsSection> createState() => _TutorsSectionState();
}

class _TutorsSectionState extends State<_TutorsSection> {
  static const int _pageSize = 4;
  int _visibleCount = _pageSize;

  final List<_TutorData> _tutors = const [
    _TutorData(
      name: 'João Ribeiro',
      country: 'Reino Unido',
      rating: 4.9,
      reviewCount: 84,
      description:
          'Especialista em Inglês para iniciantes e preparação para exames. Nativo de Inglaterra com 10 anos de experiência.',
      lessonsText: '1205+ aulas',
      pricePerHour: 15,
      tags: ['Conversação', 'IELTS', 'Business English'],
    ),
    _TutorData(
      name: 'Ana Costa',
      country: 'Portugal',
      rating: 4.8,
      reviewCount: 61,
      description:
          'Focada em gramática e preparação para exames. Aulas personalizadas e materiais próprios.',
      lessonsText: '980+ aulas',
      pricePerHour: 14,
      tags: ['Gramática', 'TOEFL', 'Cambridge'],
    ),
    _TutorData(
      name: 'Miguel Santos',
      country: 'Irlanda',
      rating: 4.7,
      reviewCount: 40,
      description:
          'Business English e conversação. Ajuda com entrevistas e apresentações.',
      lessonsText: '700+ aulas',
      pricePerHour: 16,
      tags: ['Business English', 'Conversação', 'IELTS'],
    ),
    _TutorData(
      name: 'Maria Santos',
      country: 'Portugal',
      rating: 4.8,
      reviewCount: 156,
      description:
          'Professora certificada com foco em gramática e preparação para Cambridge. Métodos inovadores e resultados comprovados.',
      lessonsText: '1500+ aulas',
      pricePerHour: 18,
      tags: ['Gramática', 'Cambridge', 'Conversação'],
    ),
    _TutorData(
      name: 'Carlos Mendes',
      country: 'Espanha',
      rating: 4.6,
      reviewCount: 92,
      description:
          'Conversação e preparação para entrevistas. Aulas práticas com foco em fluência e confiança.',
      lessonsText: '860+ aulas',
      pricePerHour: 13,
      tags: ['Conversação', 'Entrevistas', 'Fluência'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleCount = _visibleCount.clamp(0, _tutors.length);
    final visibleTutors = _tutors.take(visibleCount).toList(growable: false);
    final hasMore = visibleCount < _tutors.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 30,
          runSpacing: 30,
          children: [
            for (final tutor in visibleTutors)
              TutorCard(
                name: tutor.name,
                country: tutor.country,
                rating: tutor.rating,
                reviewCount: tutor.reviewCount,
                description: tutor.description,
                lessonsText: tutor.lessonsText,
                pricePerHour: tutor.pricePerHour,
                tags: tutor.tags,
                onViewProfileTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.tutorProfile,
                    arguments: TutorProfileArgs(
                      name: tutor.name,
                      country: tutor.country,
                      rating: tutor.rating,
                      reviewCount: tutor.reviewCount,
                      description: tutor.description,
                      lessonsText: tutor.lessonsText,
                      pricePerHour: tutor.pricePerHour,
                      tags: const ['Falante Nativo', 'Super Explicador'],
                    ),
                  );
                },
              ),
          ],
        ),
        if (hasMore) ...[
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 220,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _visibleCount = (_visibleCount + _pageSize).clamp(0, _tutors.length);
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFC9039), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.766),
                  ),
                ),
                child: const Text(
                  'Mostrar mais',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFC9039),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
