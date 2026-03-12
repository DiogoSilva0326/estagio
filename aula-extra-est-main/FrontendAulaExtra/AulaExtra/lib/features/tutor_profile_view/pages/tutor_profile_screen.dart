import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/features/tutor_profile_view/sections/back_bar_section.dart';
import 'package:aula_extra/features/tutor_profile_view/sections/hero_section.dart';
import 'package:aula_extra/features/tutor_profile_view/sections/profile_content_section.dart';
import 'package:aula_extra/features/tutor_profile_view/sections/profile_summary_section.dart';
import 'package:aula_extra/features/tutor_profile_view/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key});

  static const TutorProfileArgs fallbackArgs = TutorProfileArgs(
    name: 'João Ribeiro',
    country: 'Reino Unido',
    rating: 4.9,
    reviewCount: 84,
    description:
        'Sou João Ribeiro, um explicador apaixonado por ensinar e ajudar alunos a alcançarem os seus objetivos. Tenho mais de 10 anos de experiência e adapto as aulas ao ritmo e necessidades de cada aluno.',
    lessonsText: '1205+ aulas dadas',
    pricePerHour: 15,
    tags: ['Falante Nativo', 'Super Explicador'],
  );

  @override
  State<TutorProfileScreen> createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
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
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final args = routeArgs is TutorProfileArgs ? routeArgs : TutorProfileScreen.fallbackArgs;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
                  const ColoredBox(
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      child: FullBleedScaledSection(child: BackBarSection()),
                    ),
                  ),
                  ColoredBox(
                    color: const Color(0xFF101828),
                    child: SizedBox(
                      width: double.infinity,
                      child: FullBleedScaledSection(child: HeroSection(name: args.name)),
                    ),
                  ),
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromRGBO(252, 144, 57, 0.05),
                          Color.fromRGBO(241, 92, 100, 0.05),
                        ],
                      ),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FullBleedScaledSection(
                        child: ProfileSummarySection(
                          name: args.name,
                          country: args.country,
                          rating: args.rating,
                          reviewCount: args.reviewCount,
                          lessonsText: args.lessonsText,
                          pricePerHour: args.pricePerHour,
                          tags: args.tags,
                        ),
                      ),
                    ),
                  ),
                  ColoredBox(
                    color: const Color(0xFFF9FAFB),
                    child: SizedBox(
                      width: double.infinity,
                      child: FullBleedScaledSection(
                        child: ProfileContentSection(description: args.description),
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
