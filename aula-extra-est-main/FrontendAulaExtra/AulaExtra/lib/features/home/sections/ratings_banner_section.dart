import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RatingsBannerSection extends StatelessWidget {
  const RatingsBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned(
            left: 126,
            top: 90,
            child: Text('4,7', style: TextStyle(fontSize: 200, fontWeight: FontWeight.w400, fontFamily: 'Gulax', color: Colors.white, height: 1)),
          ),
          Positioned(left: 433, top: 25, child: SvgPicture.asset(HomeAssets.star, width: 97.5, height: 97.5)),
          Positioned(
            left: 563,
            top: 50,
            child: Text(
              'em avaliações\nreais',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 128,
                fontFamily: 'Gulax',
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 0.85,
              ),
            ),
          ),
          const Positioned(
            left: 869,
            top: 180,
            child: SizedBox(
              width: 450,
              child: Text(
                'A qualidade dos nossos explicadores reflete-se nas avaliações: uma média de 4,7 estrelas atribuídas por quem aprende connosco.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
