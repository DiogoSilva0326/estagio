import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ComoFuncionaSection extends StatelessWidget {
  const ComoFuncionaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 660,
      width: double.infinity,
      child: Stack(
        children: const [
          Positioned(
            left: 412,
            top: 70,
            child: SizedBox(
              width: 616,
              child: Column(
                children: [
                  Text('Como Funciona', textAlign: TextAlign.center, style: TextStyle(fontSize: 64, fontWeight: FontWeight.w500, color: Colors.black, height: 0.95)),
                  SizedBox(height: 10),
                  Text(
                    'Começar é simples. Segue estes passos fáceis para iniciar a tua jornada de aprendizagem.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, height: 1.2, fontWeight: FontWeight.w500, color: Color(0xFFFAA31B)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 59,
            top: 278,
            child: _HowCard(
              number: '1',
              numberBg: HomeAssets.stepEllipse1,
              icon: HomeAssets.iconSearch,
              accentColor: Color(0xFF3B94EF),
              title: 'ENCONTRA O TEU EXPLICADOR',
              description: 'Navega pelos nossos explicadores verificados e encontra a correspondência perfeita para as tuas necessidades de aprendizagem.',
            ),
          ),
          Positioned(
            left: 408,
            top: 278,
            child: _HowCard(
              number: '2',
              numberBg: HomeAssets.stepEllipse2,
              icon: HomeAssets.iconCalendar,
              accentColor: Color(0xFF45AB61),
              title: 'AGENDA UMA SESSÃO',
              description: 'Escolhe um horário que funcione para ti. O nosso agendamento flexível adapta-se ao teu estilo de vida.',
              iconSize: 48,
            ),
          ),
          Positioned(
            left: 760,
            top: 278,
            child: _HowCard(
              number: '3',
              numberBg: HomeAssets.stepEllipse3,
              icon: HomeAssets.iconVideo,
              accentColor: Color(0xFFFDB571),
              title: 'APRENDE ONLINE',
              description: 'Liga-te por videochamada e recebe instrução personalizada individual de qualquer lugar.',
              iconSize: 48,
            ),
          ),
          Positioned(
            left: 1110,
            top: 276,
            child: _HowCard(
              number: '4',
              numberBg: HomeAssets.stepEllipse4,
              icon: HomeAssets.iconCheckCircle,
              accentColor: Color(0xFFF15C64),
              title: 'ACOMPANHA O PROGRESSO',
              description: 'Monitoriza a tua evolução com relatórios de progresso detalhados e feedback do teu explicador.',
              iconSize: 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowCard extends StatelessWidget {
  const _HowCard({
    required this.number,
    required this.numberBg,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    this.iconSize = 48,
  });

  final String number;
  final String numberBg;
  final String icon;
  final Color accentColor;
  final String title;
  final String description;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 269.0;
    const double accentHeight = 132.0;
    const double borderRadiusValue = 20.0;

    // Novo tamanho do número ainda maior
    const double badgeSize = 56.0;

    return SizedBox(
      width: cardWidth,
      height: 380, // Aumentado ligeiramente para comportar o badge maior
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. O Retângulo do Figma (Fundo Colorido)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: cardWidth,
              height: accentHeight,
              decoration: ShapeDecoration(
                color: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadiusValue),
                ),
              ),
            ),
          ),

          // 2. O Corpo Branco (Sobreposto)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(borderRadiusValue),
                border: Border.all(
                  color: accentColor.withAlpha(((accentColor.a * 0.2) * 255.0).round().clamp(0, 255).toInt()),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(((Colors.black.a * 0.06) * 255.0).round().clamp(0, 255).toInt()),
                    offset: const Offset(0, 12),
                    blurRadius: 20,
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 90, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black.withAlpha(((Colors.black.a * 0.6) * 255.0).round().clamp(0, 255).toInt()),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Ícone
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                icon,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
              ),
            ),
          ),

          // 4. Número (Badge) - MAIOR e SEM borda branca
          Positioned(
            right: -15, // Ajustado para não colidir com o texto
            top: -15,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                // Removida a borda branca (Border.all removido daqui)
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withAlpha(((accentColor.a * 0.4) * 255.0).round().clamp(0, 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 24, // Texto aumentado para 24
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
