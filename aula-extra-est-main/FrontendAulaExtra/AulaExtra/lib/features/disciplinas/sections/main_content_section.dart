import 'package:aula_extra/features/disciplinas/sections/popular_areas_section.dart';
import 'package:aula_extra/features/disciplinas/widgets/search_bar.dart';
import 'package:flutter/material.dart';

class MainContentSection extends StatelessWidget {
  const MainContentSection({super.key});

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
              children: const [
                _HeaderBlock(),
                SizedBox(height: 24),
                DisciplinasSearchBar(),
                SizedBox(height: 40),
                PopularAreasSection(),
                SizedBox(height: 76),
                _RatingsBanner(),
                SizedBox(height: 74),
                _CtaRow(),
                SizedBox(height: 90),
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


class _RatingsBanner extends StatelessWidget {
  const _RatingsBanner();

  static const double _designWidth = 949.787;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define a largura máxima baseada no pai ou no design original
        final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : _designWidth;
        // Fator de escala para manter a proporção em diferentes telas
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
              // Use the same inner horizontal padding as the cards below (40.85)
              padding: EdgeInsets.symmetric(horizontal: 40.85 * scale, vertical: 30 * scale),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lado Esquerdo: Número e Estrela
                  SizedBox(
                    width: 210 * scale,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Transform.translate(
                          offset: Offset(0, 20 * scale),
                          child: Text(
                            '4,7',
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
                  // Lado Direito: Textos
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
                                  'A qualidade dos nossos explicadores reflete-se \n nas avaliações: uma média de 4,7 estrelas \n atribuídas por quem aprende connosco.',
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
        children: const [
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
            ),
          ),
          SizedBox(width: 30.638),
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
  });

  final String title;
  final String description;
  final Gradient gradient;
  final String buttonText;
  final Color buttonTextColor;

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
            Container(
              height: 61.277,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.766),
              ),
              child: Center(
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
