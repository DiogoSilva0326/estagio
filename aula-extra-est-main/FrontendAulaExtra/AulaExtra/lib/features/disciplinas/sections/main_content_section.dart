import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/global_professor_rating_summary_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/navigation/become_teacher_navigation.dart';
import 'package:aula_extra/features/disciplinas/sections/popular_areas_section.dart';
import 'package:aula_extra/features/disciplinas/widgets/search_bar.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class MainContentSection extends StatelessWidget {
  const MainContentSection({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.areas,
    required this.disciplinas,
    required this.selectedArea,
    required this.onAreaSelected,
    required this.onClearArea,
    required this.loading,
    this.error,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<AreaDto> areas;
  final List<DisciplinaDto> disciplinas;
  final AreaDto? selectedArea;
  final ValueChanged<String> onAreaSelected;
  final VoidCallback onClearArea;
  final bool loading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(left: 40.85),
          child: SizedBox(
            width: 949.787,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _HeaderBlock(),
                const SizedBox(height: 24),
                DisciplinasSearchBar(
                  controller: searchController,
                  onChanged: onSearchChanged,
                ),
                const SizedBox(height: 40),
                if (loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      error!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF4A5565),
                      ),
                    ),
                  )
                else
                  PopularAreasSection(
                    areas: areas,
                    disciplinas: disciplinas,
                    selectedArea: selectedArea,
                    onAreaSelected: onAreaSelected,
                    onClearArea: onClearArea,
                  ),
                const SizedBox(height: 76),
                const _RatingsBanner(),
                const SizedBox(height: 74),
                const _CtaRow(),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Disciplinas',
          style: TextStyle(
            fontSize: 45.957,
            height: 1.11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A0A0A),
          ),
        ),
        SizedBox(height: 10.213),
        Text(
          'Escolhe uma área ou disciplina específica para encontrar o explicador perfeito para ti',
          style: TextStyle(
            fontSize: 20.426,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: Color(0xFF4A5565),
          ),
        ),
      ],
    );
  }
}


class _RatingsBanner extends StatefulWidget {
  const _RatingsBanner();

  @override
  State<_RatingsBanner> createState() => _RatingsBannerState();
}

class _RatingsBannerState extends State<_RatingsBanner> {
  final ProfessorsService _professorsService = ProfessorsService();
  late final Future<GlobalProfessorRatingSummaryDto> _ratingSummaryFuture =
      _professorsService.getGlobalRatingSummary();

  String _formatRating(double value) =>
      value.toStringAsFixed(1).replaceAll('.', ',');

  static const double _designWidth = 949.787;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GlobalProfessorRatingSummaryDto>(
      future: _ratingSummaryFuture,
      builder: (context, snapshot) {
        final summary = snapshot.data ??
            const GlobalProfessorRatingSummaryDto(avgRating: 0, reviewCount: 0);
        final ratingText = _formatRating(summary.avgRating);

        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : _designWidth;
            final scale = (maxWidth / _designWidth).clamp(0.0, 1.0);

            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(right: 40.85 * scale),
              constraints: BoxConstraints(minHeight: 219 * scale),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.532),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.85 * scale, vertical: 30 * scale),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 210 * scale,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Transform.translate(
                            offset: Offset(0, 20 * scale),
                            child: Text(
                              ratingText,
                              style: TextStyle(
                                fontFamily: 'Gulax',
                                fontSize: 130 * scale,
                                height: 1.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -50 * scale,
                            left: 190 * scale,
                            top: -40 * scale,
                            child: Icon(
                              Icons.star,
                              size: 75 * scale,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 70 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'em avaliações',
                            style: TextStyle(
                              fontFamily: 'Gulax',
                              fontSize: 80 * scale,
                              height: 0.9,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                'reais',
                                style: TextStyle(
                                  fontFamily: 'Gulax',
                                  fontSize: 80 * scale,
                                  height: 0.9,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 15 * scale),
                              Expanded(
                                child: Transform.translate(
                                  offset: Offset(0, -35 * scale),
                                  child: Text(
                                    'A qualidade dos nossos explicadores reflete-se \n nas avaliações: uma média de $ratingText estrelas \n atribuídas por quem aprende connosco.',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14 * scale,
                                      height: 1.2,
                                      color: const Color.fromRGBO(255, 255, 255, 0.9),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CtaRow extends StatelessWidget {
  const _CtaRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 949.787,
      height: 326.809,
      child: Row(
        children: [
          Expanded(
            child: _CtaCard(
              title: 'Queres Aprender?',
              description: 'Encontra explicadores especialistas em qualquer disciplina e começa a aprender hoje',
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFC9039), Color(0xFFFAA31B)],
              ),
              buttonText: 'Começar',
              buttonTextColor: Color(0xFFFC9039),
              onPressed: () => Navigator.of(context).pushNamed(Routes.explicadores),
            ),
          ),
          const SizedBox(width: 30.638),
          Expanded(
            child: _CtaCard(
              title: 'Queres Ensinar?',
              description: 'Junta-te à nossa comunidade de explicadores e partilha o teu conhecimento',
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF15C64), Color(0xFFFC9039)],
              ),
              buttonText: 'Inscrever',
              buttonTextColor: Color(0xFFF15C64),
              onPressed: () => navigateToBecomeTeacherFlow(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  const _CtaCard({
    required this.title,
    required this.description,
    required this.gradient,
    required this.buttonText,
    required this.buttonTextColor,
    required this.onPressed,
  });

  final String title;
  final String description;
  final Gradient gradient;
  final String buttonText;
  final Color buttonTextColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.532),
        gradient: gradient,
      ),
      child: Padding(
        padding: const EdgeInsets.all(40.85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 30.638,
                height: 1.333,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20.426),
            Text(
              description,
              style: const TextStyle(
                fontSize: 20.426,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            SizedBox(
              height: 61.277,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: buttonTextColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.766),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontSize: 20.426,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: buttonTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
