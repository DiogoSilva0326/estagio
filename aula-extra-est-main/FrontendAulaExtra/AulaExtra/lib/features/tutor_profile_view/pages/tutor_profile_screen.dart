import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/professors/dtos/public_professor_profile_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/features/tutor_profile_view/sections/back_bar_section.dart';
import 'package:aula_extra/features/tutor_profile_view/constants/tutor_profile_layout.dart';
import 'package:aula_extra/features/tutor_profile_view/sections/hero_section.dart';
import 'package:aula_extra/features/tutor_profile_view/sections/profile_content_section.dart';
import 'package:aula_extra/features/tutor_profile_view/sections/profile_summary_section.dart';
import 'package:aula_extra/features/tutor_profile_view/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class TutorProfileScreen extends StatefulWidget {
  const TutorProfileScreen({super.key});

  static const TutorProfileArgs fallbackArgs = TutorProfileArgs(
    professorId: '',
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
  final ProfessorsService _professors = ProfessorsService();
  late final ScrollController _scrollController;
  PublicProfessorProfileDto? _profile;
  String? _loadedProfessorId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final args = routeArgs is TutorProfileArgs
        ? routeArgs
        : TutorProfileScreen.fallbackArgs;

    if (_loadedProfessorId == args.professorId) return;
    _loadedProfessorId = args.professorId;
    _loadProfile(args.professorId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile(String professorId) async {
    if (professorId.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _profile = null;
      });
      return;
    }

    try {
      final profile = await _professors.getPublicProfessorProfile(
        idProfessor: professorId,
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final args = routeArgs is TutorProfileArgs
        ? routeArgs
        : TutorProfileScreen.fallbackArgs;
    final profile = _profile;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobileLayout = screenWidth <= kTutorProfileMobileBreakpoint;

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
                height: AppHeader.resolvedHeight(context),
                child: AppHeader(
                  onRegisterTap: () =>
                      Navigator.of(context).pushNamed(Routes.registerStudent),
                  onLoginTap: () =>
                      Navigator.of(context).pushNamed(Routes.login),
                  onLogoTap: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.home, (route) => false),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ColoredBox(
                    color: Colors.white,
                    child: SizedBox(
                      width: double.infinity,
                      child: _ResponsiveSection(
                        isMobile: isMobileLayout,
                        child: const BackBarSection(),
                      ),
                    ),
                  ),
                  ColoredBox(
                    color: const Color(0xFF101828),
                    child: SizedBox(
                      width: double.infinity,
                      child: _ResponsiveSection(
                        isMobile: isMobileLayout,
                        child: HeroSection(
                          name: profile?.displayName ?? args.name,
                          photoUrl: profile?.photo,
                          presentationVideoUrl: profile?.presentationVideoUrl,
                          isVerified: profile?.isVerified ?? false,
                        ),
                      ),
                    ),
                  ),
                  isMobileLayout
                      ? DecoratedBox(
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
                            child: _ResponsiveSection(
                              isMobile: true,
                              child: ProfileSummarySection(
                                name: profile?.displayName ?? args.name,
                                photoUrl: profile?.photo,
                                isVerified: profile?.isVerified ?? false,
                                country: args.country,
                                rating: profile?.stats.avgRating ?? args.rating,
                                reviewCount:
                                    profile?.stats.reviewCount ??
                                    args.reviewCount,
                                lessonsText:
                                    (profile?.stats.lessonsCount ?? 0) > 0
                                    ? '${profile!.stats.lessonsCount} aulas dadas'
                                    : args.lessonsText,
                                pricePerHour: args.pricePerHour,
                                tags: _buildTags(profile, args),
                              ),
                            ),
                          ),
                        )
                      : ClipPath(
                          clipper: const _ProfileSummaryBackgroundClipper(),
                          child: DecoratedBox(
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
                              child: _ResponsiveSection(
                                isMobile: false,
                                child: ProfileSummarySection(
                                  name: profile?.displayName ?? args.name,
                                  photoUrl: profile?.photo,
                                  isVerified: profile?.isVerified ?? false,
                                  country: args.country,
                                  rating:
                                      profile?.stats.avgRating ?? args.rating,
                                  reviewCount:
                                      profile?.stats.reviewCount ??
                                      args.reviewCount,
                                  lessonsText:
                                      (profile?.stats.lessonsCount ?? 0) > 0
                                      ? '${profile!.stats.lessonsCount} aulas dadas'
                                      : args.lessonsText,
                                  pricePerHour: args.pricePerHour,
                                  tags: _buildTags(profile, args),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ColoredBox(
                    color: const Color(0xFFF9FAFB),
                    child: SizedBox(
                      width: double.infinity,
                      child: _ResponsiveSection(
                        isMobile: isMobileLayout,
                        child: ProfileContentSection(
                          description:
                              profile?.biography?.trim().isNotEmpty == true
                              ? profile!.biography!.trim()
                              : args.description,
                          currentSchool: profile?.currentSchool,
                          yearsExperience: profile?.yearsExperience,
                          website: profile?.website,
                          availability: profile?.availability ?? const [],
                          languages: profile?.languages ?? const [],
                          disciplinas: profile?.disciplinas ?? const [],
                          certificates: profile?.certificates ?? const [],
                          reviews: profile?.reviews ?? const [],
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

  List<String> _buildTags(
    PublicProfessorProfileDto? profile,
    TutorProfileArgs args,
  ) {
    if (args.tags.isNotEmpty) {
      return args.tags.take(2).toList(growable: false);
    }

    if (profile == null) return args.tags;

    final values = <String>[];
    if (profile.isVerified) values.add('Perfil Verificado');
    if (profile.languages.isNotEmpty) {
      final language = profile.languages.first;
      final level = language.proficiencyLevel?.trim();
      values.add(
        level == null || level.isEmpty
            ? language.nome
            : '${language.nome} ($level)',
      );
    }

    final seen = <String>{};
    return values
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty && seen.add(item.toLowerCase()))
        .take(2)
        .toList(growable: false);
  }
}

class _ResponsiveSection extends StatelessWidget {
  const _ResponsiveSection({required this.isMobile, required this.child});

  final bool isMobile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isMobile) {
      return FullBleedScaledSection(child: child);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: kTutorProfileMobileContentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}

class _ProfileSummaryBackgroundClipper extends CustomClipper<Path> {
  const _ProfileSummaryBackgroundClipper();

  static const double _avatarLeft = 40.851;
  static const double _avatarSize = 204.255;
  static const double _cutoutRadius = 112;

  @override
  Path getClip(Size size) {
    final path = Path()..fillType = PathFillType.evenOdd;
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addOval(
      Rect.fromCircle(
        center: const Offset(_avatarLeft + (_avatarSize / 2), 0),
        radius: _cutoutRadius,
      ),
    );
    return path;
  }

  @override
  bool shouldReclip(covariant _ProfileSummaryBackgroundClipper oldClipper) =>
      false;
}
