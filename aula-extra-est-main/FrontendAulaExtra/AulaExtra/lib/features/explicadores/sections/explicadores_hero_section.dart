import 'package:flutter/material.dart';

class ExplicadoresHeroSection extends StatelessWidget {
  const ExplicadoresHeroSection({super.key});

  static const _paddingTop = 61.277;

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: _paddingTop),
      child: _HeroContent(),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400.809,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned(
            left: 40.85,
            top: 0,
            child: Text(
              'Explicadores Online',
              style: TextStyle(
                fontSize: 61.277,
                height: 1,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const Positioned(
            left: 40.85,
            top: 81.7,
            child: SizedBox(
              width: 980.426,
              child: Text(
                'Encontra o explicador perfeito para ti, desde a primária até à universidade. Personaliza a tua busca por preço, disponibilidade e mais.',
                style: TextStyle(
                  fontSize: 25.532,
                  height: 35.745 / 25.532,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 40.85,
            top: 183.83,
            child: SizedBox(
              height: 35.745,
              width: 1358.298,
              child: Row(
                children: const [
                  _HeroStat(
                    icon: Icons.people_alt_outlined,
                    text: '500+ explicadores disponíveis',
                    width: 367.879,
                  ),
                  SizedBox(width: 40.851),
                  _HeroStat(
                    icon: Icons.star_border,
                    text: '4.7 estrelas médias',
                    width: 248.717,
                  ),
                  SizedBox(width: 40.851),
                  _HeroStat(
                    icon: Icons.play_circle_outline,
                    text: '50.000+ aulas realizadas',
                    width: 310.462,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 40.85,
            top: 250.21,
            child: SizedBox(
              width: 346.127,
              height: 76.596,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12.766)),
                ),
                child: Center(
                  child: Text(
                    'Personalizar Resultados',
                    style: TextStyle(
                      fontSize: 22.979,
                      height: 35.745 / 22.979,
                      fontWeight: FontWeight.w700,
                      
                      color: Color(0xFFFC9039),
                    ),
                    
                  ),
                ),
                
              ),
            ),
            
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.text,
    required this.width,
  });

  final IconData icon;
  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Icon(icon, size: 30.638, color: Colors.white),
          const SizedBox(width: 10.213),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 22.979,
                height: 35.745 / 22.979,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
