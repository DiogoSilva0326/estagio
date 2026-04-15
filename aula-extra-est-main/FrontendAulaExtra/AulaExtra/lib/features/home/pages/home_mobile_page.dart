import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/professors/dtos/global_professor_rating_summary_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/data/tutors/dtos/tutor_browse_item_dto.dart';
import 'package:aula_extra/core/data/tutors/tutors_browse_service.dart';
import 'package:aula_extra/core/navigation/become_teacher_navigation.dart';
import 'package:aula_extra/features/explicadores/pages/explicadores_screen.dart';
import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:aula_extra/features/home/constants/home_layout.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeMobilePage extends StatelessWidget {
  const HomeMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: kHomeMobileContentMaxWidth,
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MobileHeroSection(),
                          ColoredBox(
                            color: Color(0xFFF9F9F9),
                            child: _MobileAreasSection(),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
                              ),
                            ),
                            child: _MobileRatingsSection(),
                          ),
                          _MobileHowItWorksSection(),
                          ColoredBox(
                            color: Color(0xFFF9F9F9),
                            child: _MobileTutorsSection(),
                          ),
                          ColoredBox(
                            color: Color(0xFFF9F9F9),
                            child: _MobileCtaSection(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ColoredBox(color: Color(0xFFF9F9F9), child: FooterSection()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileHeroSection extends StatefulWidget {
  const _MobileHeroSection();

  @override
  State<_MobileHeroSection> createState() => _MobileHeroSectionState();
}

class _MobileHeroSectionState extends State<_MobileHeroSection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    Navigator.of(context).pushNamed(
      Routes.explicadores,
      arguments: ExplicadoresScreenArgs(initialQuery: query),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Encontra o melhor apoio para ti.',
            style: TextStyle(
              fontSize: 44,
              height: 0.98,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Conecta-te com explicadores especialistas para aulas online personalizadas. Domina qualquer disciplina ao teu próprio ritmo com orientação individual.',
            style: TextStyle(
              fontSize: 18,
              height: 1.33,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFAA31B),
            ),
          ),
          const SizedBox(height: 22),
          const _HeroStatsColumn(),
          const SizedBox(height: 22),
          _MobileSearchField(
            controller: _searchController,
            onSubmitted: (_) => _submitSearch(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _submitSearch,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFF15C64),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Encontrar Explicador',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const _MobileTeacherImageCard(
            imageAsset: HomeAssets.teacherFrame7,
            name: 'JOÃO',
            subject: 'Matemática',
          ),
          const SizedBox(height: 16),
          _MobileInfoCard(
            backgroundColor: const Color(0xCCFC9039),
            title: 'EXPLICADORES VERIFICADOS',
            description:
                'Todos os explicadores são verificados e especialistas nas suas disciplinas.',
            buttonLabel: 'Tornar-me um Explicador',
            buttonColor: const Color(0xFFFC9039),
            onPressed: () => navigateToBecomeTeacherFlow(context),
          ),
          const SizedBox(height: 16),
          const _MobileTeacherImageCard(
            imageAsset: HomeAssets.teacherFrame8,
            name: 'ANDRÉ',
            subject: 'Física',
          ),
          const SizedBox(height: 16),
          const _MobileSimpleHighlightCard(
            backgroundColor: Color(0x9965A7D7),
            title: 'APRENDIZAGEM PERSONALIZADA',
            description:
                'Sessões individuais adaptadas ao teu estilo de aprendizagem e objetivos.',
          ),
          const SizedBox(height: 16),
          const _MobileTeacherImageCard(
            imageAsset: HomeAssets.teacherFrame12,
            name: 'ANDREIA',
            subject: 'Inglês',
          ),
          const SizedBox(height: 16),
          _MobileInfoCard(
            backgroundColor: const Color(0xCCF15C64),
            title: 'HORÁRIOS FLEXÍVEIS',
            description:
                'Aprende ao teu próprio ritmo e marca sessões que se ajustam à tua agenda.',
            buttonLabel: 'Marcar uma Sessão',
            buttonColor: const Color(0xFFF15C64),
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.explicadores),
          ),
        ],
      ),
    );
  }
}

class _HeroStatsColumn extends StatelessWidget {
  const _HeroStatsColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroStatLine(
          value: '5.000+',
          label: 'Explicadores Especialistas',
          color: Color(0xFF3B94EF),
        ),
        SizedBox(height: 16),
        _HeroStatLine(
          value: '50.000+',
          label: 'Alunos Satisfeitos',
          color: Color(0xFFFC9039),
        ),
        SizedBox(height: 16),
        _HeroStatLine(
          value: '100+',
          label: 'Disciplinas',
          color: Color(0xFF45AB61),
        ),
      ],
    );
  }
}

class _HeroStatLine extends StatelessWidget {
  const _HeroStatLine({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 30,
            height: 1.05,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            height: 1.2,
            color: Color(0xFF6F7682),
          ),
        ),
      ],
    );
  }
}

class _MobileSearchField extends StatelessWidget {
  const _MobileSearchField({
    required this.controller,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFEFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6E9EA)),
      ),
      child: Row(
        children: [
          Image.asset(
            HomeAssets.searchIcon,
            width: 16,
            height: 16,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Procurar disciplinas...',
                hintStyle: TextStyle(fontSize: 16, color: Color(0xFFBCBDBB)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileTeacherImageCard extends StatelessWidget {
  const _MobileTeacherImageCard({
    required this.imageAsset,
    required this.name,
    required this.subject,
  });

  final String imageAsset;
  final String name;
  final String subject;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 256,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              imageAsset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xE6FFFFFF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0x99000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF15C64),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        HomeAssets.star,
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileInfoCard extends StatelessWidget {
  const _MobileInfoCard({
    required this.backgroundColor,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onPressed,
  });

  final Color backgroundColor;
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              height: 1,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileSimpleHighlightCard extends StatelessWidget {
  const _MobileSimpleHighlightCard({
    required this.backgroundColor,
    required this.title,
    required this.description,
  });

  final Color backgroundColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              height: 1,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileAreasSection extends StatefulWidget {
  const _MobileAreasSection();

  @override
  State<_MobileAreasSection> createState() => _MobileAreasSectionState();
}

class _MobileAreasSectionState extends State<_MobileAreasSection> {
  final EducationService _educationService = EducationService();
  late final Future<List<AreaDto>> _areasFuture = _loadAreas();

  Future<List<AreaDto>> _loadAreas() async {
    final areas = await _educationService.getPublicAreas();
    final normalized = areas
        .where((area) => area.nome.trim().isNotEmpty)
        .toList(growable: false);
    normalized.sort(
      (left, right) =>
          left.nome.toLowerCase().compareTo(right.nome.toLowerCase()),
    );
    return normalized.take(8).toList(growable: false);
  }

  String _subtitleFor(AreaDto area) {
    if (area.professorCount == 1) {
      return '1 explicador';
    }
    return '${area.professorCount} explicadores';
  }

  String _iconAssetFor(String areaName) {
    final normalized = areaName.trim().toLowerCase();
    if (normalized.contains('mat')) return HomeAssets.areaMatematica;
    if (normalized.contains('ci') ||
        normalized.contains('bio') ||
        normalized.contains('fis') ||
        normalized.contains('quim')) {
      return HomeAssets.areaCiencias;
    }
    if (normalized.contains('ling') ||
        normalized.contains('ingl') ||
        normalized.contains('portugu')) {
      return HomeAssets.areaLinguas;
    }
    if (normalized.contains('liter')) return HomeAssets.areaLiteratura;
    if (normalized.contains('program') ||
        normalized.contains('inform') ||
        normalized.contains('tec')) {
      return HomeAssets.areaProgramacao;
    }
    if (normalized.contains('geo') || normalized.contains('hist')) {
      return HomeAssets.areaGeografia;
    }
    if (normalized.contains('mús') || normalized.contains('mus')) {
      return HomeAssets.areaMusica;
    }
    return HomeAssets.areaArtes;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _MobileSectionTitle(
            title: 'Áreas Populares',
            subtitle:
                'Escolhe entre uma vasta gama de áreas lecionadas por explicadores especialistas',
          ),
          const SizedBox(height: 32),
          FutureBuilder<List<AreaDto>>(
            future: _areasFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const Text(
                  'Não foi possível carregar as áreas populares.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Color(0xFFB42318)),
                );
              }

              final areas = snapshot.data ?? const <AreaDto>[];
              if (areas.isEmpty) {
                return const Text(
                  'Ainda não existem áreas disponíveis.',
                  textAlign: TextAlign.center,
                );
              }

              return Column(
                children: [
                  for (final area in areas) ...[
                    _MobileAreaCard(
                      title: area.nome.toUpperCase(),
                      subtitle: _subtitleFor(area),
                      iconAsset: _iconAssetFor(area.nome),
                    ),
                    if (area != areas.last) const SizedBox(height: 16),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.disciplinas),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFF15C64),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Ver Todas as Áreas'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileAreaCard extends StatelessWidget {
  const _MobileAreaCard({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
  });

  final String title;
  final String subtitle;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(iconAsset, width: 48, height: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileRatingsSection extends StatefulWidget {
  const _MobileRatingsSection();

  @override
  State<_MobileRatingsSection> createState() => _MobileRatingsSectionState();
}

class _MobileRatingsSectionState extends State<_MobileRatingsSection> {
  final ProfessorsService _professorsService = ProfessorsService();
  late final Future<GlobalProfessorRatingSummaryDto> _ratingSummaryFuture =
      _professorsService.getGlobalRatingSummary();

  String _formatRating(double value) =>
      value.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GlobalProfessorRatingSummaryDto>(
      future: _ratingSummaryFuture,
      builder: (context, snapshot) {
        final summary =
            snapshot.data ??
            const GlobalProfessorRatingSummaryDto(avgRating: 0, reviewCount: 0);
        final ratingText = _formatRating(summary.avgRating);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 48),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ratingText,
                    style: const TextStyle(
                      fontSize: 60,
                      height: 1,
                      fontFamily: 'Gulax',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(HomeAssets.star, width: 42, height: 42),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'em avaliações reais',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  height: 0.95,
                  fontFamily: 'Gulax',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A qualidade dos nossos explicadores reflete-se nas avaliações: uma média de $ratingText estrelas atribuídas por quem aprende connosco.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.35,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MobileHowItWorksSection extends StatelessWidget {
  const _MobileHowItWorksSection();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        number: '1',
        icon: HomeAssets.iconSearch,
        color: Color(0xFF3B94EF),
        title: 'ENCONTRA O TEU EXPLICADOR',
        description:
            'Navega pelos nossos explicadores verificados e encontra a correspondência perfeita para as tuas necessidades de aprendizagem.',
      ),
      (
        number: '2',
        icon: HomeAssets.iconCalendar,
        color: Color(0xFF45AB61),
        title: 'AGENDA UMA SESSÃO',
        description:
            'Escolhe um horário que funcione para ti. O nosso agendamento flexível adapta-se ao teu estilo de vida.',
      ),
      (
        number: '3',
        icon: HomeAssets.iconVideo,
        color: Color(0xFFFDB571),
        title: 'APRENDE ONLINE',
        description:
            'Liga-te por videochamada e recebe instrução personalizada individual de qualquer lugar.',
      ),
      (
        number: '4',
        icon: HomeAssets.iconCheckCircle,
        color: Color(0xFFF15C64),
        title: 'ACOMPANHA O PROGRESSO',
        description:
            'Monitoriza a tua evolução com relatórios de progresso detalhados e feedback do teu explicador.',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 48),
      child: Column(
        children: [
          const _MobileSectionTitle(
            title: 'Como Funciona',
            subtitle:
                'Começar é simples. Segue estes passos fáceis para iniciar a tua jornada de aprendizagem.',
          ),
          const SizedBox(height: 32),
          for (final step in steps) ...[
            _MobileStepCard(
              number: step.number,
              icon: step.icon,
              accentColor: step.color,
              title: step.title,
              description: step.description,
            ),
            if (step != steps.last) const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _MobileStepCard extends StatelessWidget {
  const _MobileStepCard({
    required this.number,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
  });

  final String number;
  final String icon;
  final Color accentColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            offset: Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    icon,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              height: 1.05,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.35,
              color: Color(0xCC000000),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileTutorsSection extends StatefulWidget {
  const _MobileTutorsSection();

  @override
  State<_MobileTutorsSection> createState() => _MobileTutorsSectionState();
}

class _MobileTutorsSectionState extends State<_MobileTutorsSection> {
  final TutorsBrowseService _tutorsBrowseService = TutorsBrowseService();
  late final Future<List<TutorBrowseItemDto>> _featuredTutorsFuture =
      _loadFeaturedTutors();

  Future<List<TutorBrowseItemDto>> _loadFeaturedTutors() async {
    final result = await _tutorsBrowseService.browse(page: 1, pageSize: 4);
    return result.items.take(2).toList(growable: false);
  }

  String _priceText(TutorBrowseItemDto tutor) {
    if (tutor.minPrice <= 0) return 'Preço sob consulta';
    final formatted = tutor.minPrice == tutor.minPrice.roundToDouble()
        ? tutor.minPrice.round().toString()
        : tutor.minPrice.toStringAsFixed(0);
    return '€$formatted/h';
  }

  String _subjectFor(TutorBrowseItemDto tutor) {
    if (tutor.primarySubject.trim().isNotEmpty) return tutor.primarySubject;
    if (tutor.tags.isNotEmpty) return tutor.tags.first;
    return 'Explicador';
  }

  String? _resolvedPhotoUrl(String? rawValue) {
    final normalized = rawValue?.trim() ?? '';
    if (normalized.isEmpty) return null;

    final absoluteUri = Uri.tryParse(normalized);
    if (absoluteUri != null && absoluteUri.hasScheme) {
      return absoluteUri.toString();
    }

    final baseUri = Uri.parse(
      ApiConfig.baseUrl.endsWith('/')
          ? ApiConfig.baseUrl
          : '${ApiConfig.baseUrl}/',
    );
    final sanitized = normalized.replaceAll('\\', '/');
    return baseUri
        .resolve(sanitized.startsWith('/') ? sanitized.substring(1) : sanitized)
        .toString();
  }

  void _openTutorProfile(BuildContext context, TutorBrowseItemDto tutor) {
    Navigator.of(context).pushNamed(
      Routes.tutorProfile,
      arguments: TutorProfileArgs(
        professorId: tutor.idProfessor,
        name: tutor.name,
        country: tutor.subtitle.isNotEmpty ? tutor.subtitle : 'Online',
        rating: tutor.rating,
        reviewCount: tutor.reviewCount,
        description: tutor.description,
        lessonsText: '${tutor.lessonsCount} aulas',
        pricePerHour: tutor.minPrice.round(),
        tags: tutor.educationLevels.isNotEmpty
            ? tutor.educationLevels
            : tutor.tags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 48),
      child: Column(
        children: [
          const _MobileSectionTitle(
            title: 'Conhece os Nossos Explicadores Especialistas',
            subtitle:
                'Aprende com profissionais verificados e com anos de experiência de ensino',
          ),
          const SizedBox(height: 32),
          FutureBuilder<List<TutorBrowseItemDto>>(
            future: _featuredTutorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError) {
                return const Text(
                  'Não foi possível carregar os explicadores.',
                  textAlign: TextAlign.center,
                );
              }

              final tutors = snapshot.data ?? const <TutorBrowseItemDto>[];
              if (tutors.isEmpty) {
                return const Text(
                  'Ainda não existem explicadores disponíveis.',
                  textAlign: TextAlign.center,
                );
              }

              return Column(
                children: [
                  for (final tutor in tutors) ...[
                    _MobileTutorCard(
                      photoUrl: _resolvedPhotoUrl(tutor.photo),
                      name: tutor.name.toUpperCase(),
                      subject: _subjectFor(tutor),
                      rating: tutor.rating.toStringAsFixed(1),
                      price: _priceText(tutor),
                      onPressed: () => _openTutorProfile(context, tutor),
                    ),
                    if (tutor != tutors.last) const SizedBox(height: 16),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.explicadores),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFF15C64),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Ver Todos os Explicadores'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileTutorCard extends StatelessWidget {
  const _MobileTutorCard({
    required this.photoUrl,
    required this.name,
    required this.subject,
    required this.rating,
    required this.price,
    required this.onPressed,
  });

  final String? photoUrl;
  final String name;
  final String subject;
  final String rating;
  final String price;
  final VoidCallback onPressed;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'P';
    if (parts.length == 1) return parts.first.substring(0, 1);
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 192,
            width: double.infinity,
            child: photoUrl?.trim().isNotEmpty == true
                ? Image.network(
                    photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallback(),
                  )
                : _buildFallback(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFAA31B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (var index = 0; index < 5; index++) ...[
                      SvgPicture.asset(
                        HomeAssets.starFilled,
                        width: 16,
                        height: 16,
                      ),
                      if (index < 4) const SizedBox(width: 4),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFF15C64),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Ver Perfil'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MobileCtaSection extends StatelessWidget {
  const _MobileCtaSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
      child: Column(
        children: [
          _MobileCtaCard(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF48086), Color(0xFFF15C64)],
            ),
            title: 'Queres Aprender?',
            description:
                'Encontra o explicador ideal para as tuas necessidades e começa hoje.',
            buttonLabel: 'Registar-me',
            buttonColor: const Color(0xFFF15C64),
            onPressed: () =>
                Navigator.of(context).pushNamed(Routes.registerStudent),
          ),
          const SizedBox(height: 16),
          _MobileCtaCard(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFDB571), Color(0xFFFC9039)],
            ),
            title: 'Queres Ensinar?',
            description:
                'Partilha os teus conhecimentos e ajuda alunos a alcançar melhores resultados.',
            buttonLabel: 'Tornar-me Explicador',
            buttonColor: const Color(0xFFFC9039),
            onPressed: () => navigateToBecomeTeacherFlow(context),
          ),
        ],
      ),
    );
  }
}

class _MobileCtaCard extends StatelessWidget {
  const _MobileCtaCard({
    required this.gradient,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onPressed,
  });

  final Gradient gradient;
  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              height: 1,
              fontFamily: 'Gulax',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.35,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileSectionTitle extends StatelessWidget {
  const _MobileSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 36,
            height: 1.05,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFAA31B),
          ),
        ),
      ],
    );
  }
}
