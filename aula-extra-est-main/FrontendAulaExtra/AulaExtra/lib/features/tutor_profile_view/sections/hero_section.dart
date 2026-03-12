import 'package:flutter/material.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 408.511,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E2939), Color(0xFF101828)],
                ),
              ),
              child: Opacity(
                opacity: 0.30,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF101828), Color(0xFF101828)],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 291.06,
            top: 68.94,
            child: SizedBox(
              width: 857.872,
              height: 272.0,
              child: Column(
                children: [
                  Container(
                    width: 122.553,
                    height: 122.553,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 63.83,
                          offset: Offset(0, 31.915),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.play_arrow_rounded, size: 61.277, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Olá! Sou $name',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 38.298,
                      height: 45.957 / 38.298,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10.213),
                  const SizedBox(
                    width: 790.213,
                    child: Text(
                      'Neste vídeo apresento-me e explico como posso ajudar-te a alcançar os teus objetivos de aprendizagem.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.979,
                        height: 35.745 / 22.979,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20.426,
            top: 20.426,
            child: Container(
              height: 45.957,
              padding: const EdgeInsets.symmetric(horizontal: 15.319),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.7),
                borderRadius: BorderRadius.circular(12.766),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_outlined, size: 20.426, color: Colors.white),
                  SizedBox(width: 10.213),
                  Text(
                    'Vídeo de Apresentação',
                    style: TextStyle(
                      fontSize: 17.872,
                      height: 25.532 / 17.872,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 40.851,
            top: 306.38,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 204.255,
                  height: 204.255,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 10.213),
                    color: const Color(0xFFF3F4F6),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        blurRadius: 63.83,
                        offset: Offset(0, 31.915),
                        spreadRadius: -15.319,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 90, color: Color(0xFF6A7282)),
                  ),
                ),
                Positioned(
                  right: -5,
                  bottom: -5,
                  child: Container(
                    width: 61.277,
                    height: 61.277,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 19.149,
                          offset: Offset(0, 12.766),
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 7.66,
                          offset: Offset(0, 5.106),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.verified, size: 30.638, color: Colors.white),
                    ),
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
