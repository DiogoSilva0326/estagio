import 'package:flutter/material.dart';

class AreasAlunoMobileRatingCard extends StatelessWidget {
  const AreasAlunoMobileRatingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFF15C64),
            Color(0xFFF26462),
            Color(0xFFF36C60),
            Color(0xFFF4745E),
            Color(0xFFF57B5C),
            Color(0xFFF68259),
            Color(0xFFF78956),
            Color(0xFFF79053),
            Color(0xFFF8964F),
            Color(0xFFF99D4B),
            Color(0xFFF9A347),
            Color(0xFFF9AA42),
            Color(0xFFFAB03C),
            Color(0xFFFAB735),
            Color(0xFFFABD2D),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '4,7',
                style: TextStyle(
                  fontSize: 48,
                  fontFamily: 'Gulax',
                  fontWeight: FontWeight.w400,
                  height: 1,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'em avaliações reais',
            style: TextStyle(
              fontSize: 30,
              fontFamily: 'Gulax',
              height: 1.25,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Opacity(
            opacity: 0.9,
            child: Text(
              'A qualidade dos nossos explicadores reflete-se nas avaliações: uma média de 4,7 estrelas atribuídas por quem aprende connosco.',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Helvetica Neue',
                height: 1.33,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
