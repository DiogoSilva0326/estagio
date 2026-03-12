import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExplicadoresSection extends StatelessWidget {
  const ExplicadoresSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 960,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: SizedBox(
              height: 259,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Conhece os Nossos \n Explicadores Especialistas',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 64, fontWeight: FontWeight.w500, color: Colors.black, height: 0.95),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Aprende com profissionais verificados e com anos de \n experiência de ensino',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, height: 1.2, fontWeight: FontWeight.w500, color: Color(0xFFFAA31B)),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 61,
            top: 274,
            child: _TeacherCardLarge(
              imageAsset: HomeAssets.teacherFrame7,
              name: 'JOÃO RIBEIRO',
              subject: 'Matemática',
              subjectColor: Color(0xFF8DCAE7),
              location: 'Lisboa, Portugal',
              experience: '8 anos de experiência',
              price: 'A partir de \n €25/hora',
              buttonBg: HomeAssets.buttonBgRed,
              tags: [
                _Tag(text: 'PRIMÁRIO', bg: Color(0xFFE3EFFC), fg: Color(0xFF8DCAE7)),
                _Tag(text: 'BÁSICO', bg: Color(0xFFE3EFFC), fg: Color(0xFF8DCAE7)),
              ],
            ),
          ),
          const Positioned(
            left: 410,
            top: 274,
            child: _TeacherCardLarge(
              imageAsset: HomeAssets.teacherFrame12,
              name: 'BEATRIZ SILVA',
              subject: 'Inglês',
              subjectColor: Color(0xFFFAA31B),
              location: 'Penafiel, Portugal',
              experience: '5 anos de experiência',
              price: 'A partir de \n €20/hora',
              buttonBg: HomeAssets.buttonBgBlue,
              tags: [
                _Tag(text: 'BÁSICO', bg: Color(0xFFFFEDE3), fg: Color(0xFFFAA31B)),
                _Tag(text: 'SECUNDÁRIO', bg: Color(0xFFFFEDE3), fg: Color(0xFFFAA31B)),
              ],
            ),
          ),
          const Positioned(
            left: 760,
            top: 274,
            child: _TeacherCardLarge(
              imageAsset: HomeAssets.teacherFrame26,
              name: 'ANDREIA GOMES',
              subject: 'Física',
              subjectColor: Color(0xFF45AB61),
              location: 'Braga, Portugal',
              experience: '7 anos de experiência',
              price: 'A partir de \n €25/hora',
              buttonBg: HomeAssets.buttonBgOrange,
              tags: [
                _Tag(text: 'SECUNDÁRIO', bg: Color(0xFFE3F0E6), fg: Color(0xFF45AB61)),
              ],
            ),
          ),
          const Positioned(
            left: 1110,
            top: 274,
            child: _TeacherCardLarge(
              imageAsset: HomeAssets.teacherFrame8,
              name: 'ANDRÉ MATIAS',
              subject: 'Programação',
              subjectColor: Color(0xFFF15C64),
              location: 'Lisboa, Portugal',
              experience: '8 anos de experiência',
              price: 'A partir de \n €25/hora',
              buttonBg: HomeAssets.buttonBgGreen,
              tags: [
                _Tag(text: 'JAVA', bg: Color(0xFFFFE5E6), fg: Color(0xFFED1C24)),
              ],
            ),
          ),
          Positioned(
            left: 608,
            top: 841,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF15C64),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                ),
                onPressed: () {},
                child: const Text('Ver Todos os Explicadores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherCardLarge extends StatelessWidget {
  const _TeacherCardLarge({
    required this.imageAsset,
    required this.name,
    required this.subject,
    required this.subjectColor,
    required this.location,
    required this.experience,
    required this.price,
    required this.buttonBg,
    required this.tags,
  });

  final String imageAsset;
  final String name;
  final String subject;
  final Color subjectColor;
  final String location;
  final String experience;
  final String price;
  final String buttonBg;
  final List<_Tag> tags;

  static const _cardWidth = 270.0;
  static const _cardHeight = 535.0;
  static const _imageHeight = 259.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      height: _cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 4, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            child: Image.asset(imageAsset, width: _cardWidth, height: _imageHeight, fit: BoxFit.cover),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(subject, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: subjectColor)),
                  const SizedBox(height: 10),
                  _TeacherInfoRow(iconAsset: HomeAssets.iconMapPin, text: location),
                  const SizedBox(height: 6),
                  _TeacherInfoRow(iconAsset: HomeAssets.iconAward, text: experience),
                  const SizedBox(height: 12),
                  Row(children: tags),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          price,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF696969), height: 1.1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 107,
                        height: 44,
                        child: Stack(
                          children: [
                            SvgPicture.asset(buttonBg, width: 107, height: 44, fit: BoxFit.fill),
                            const Center(
                              child: Text(
                                'Marcar\nAgora',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, height: 1.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
      ),
    );
  }
}

class _TeacherInfoRow extends StatelessWidget {
  const _TeacherInfoRow({required this.iconAsset, required this.text});

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Row(
        children: [
          SvgPicture.asset(iconAsset, width: 18, height: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0x80000000)),
            ),
          ),
        ],
      ),
    );
  }
}
