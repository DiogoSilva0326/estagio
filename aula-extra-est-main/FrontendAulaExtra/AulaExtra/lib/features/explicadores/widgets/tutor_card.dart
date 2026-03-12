import 'package:flutter/material.dart';

class TutorCard extends StatelessWidget {
  const TutorCard({
    super.key,
    required this.name,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.lessonsText,
    required this.pricePerHour,
    required this.tags,
    required this.onViewProfileTap,
  });

  final String name;
  final String country;
  final double rating;
  final int reviewCount;
  final String description;
  final String lessonsText;
  final int pricePerHour;
  final List<String> tags;
  final VoidCallback onViewProfileTap;

  static const _orange = Color(0xFFFC9039);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 470,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.277),
        borderRadius: BorderRadius.circular(20.426),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(0, 5.106),
            blurRadius: 7.66,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(0, 2.553),
            blurRadius: 5.106,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 102.128,
                      height: 102.128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _orange, width: 2.553),
                        color: const Color(0xFFF3F4F6),
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name.trim().characters.first : 'E',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 30.638,
                        height: 30.638,
                        padding: const EdgeInsets.all(5.106),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                          ),
                        ),
                        child: const Icon(Icons.verified, size: 20.426, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20.426),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 25.532,
                                height: 35.745 / 25.532,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0A0A0A),
                              ),
                            ),
                          ),
                          Container(
                            height: 51.064,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(21417702)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Super Explicador',
                                style: TextStyle(
                                  fontSize: 15.319,
                                  height: 20.426 / 15.319,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.106),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 17.872, color: Color(0xFF4A5565)),
                          const SizedBox(width: 10.213),
                          Text(
                            country,
                            style: const TextStyle(
                              fontSize: 17.872,
                              height: 25.532 / 17.872,
                              color: Color(0xFF4A5565),
                            ),
                          ),
                          const SizedBox(width: 10.213),
                          Container(
                            height: 25.532,
                            padding: const EdgeInsets.symmetric(horizontal: 10.21),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(5.106),
                            ),
                            child: const Center(
                              child: Text(
                                'Nativo',
                                style: TextStyle(
                                  fontSize: 15.319,
                                  height: 20.426 / 15.319,
                                  color: Color(0xFF1447E6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5.106),
                      Row(
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < 4 ? Icons.star : Icons.star_border,
                                size: 17.872,
                                color: const Color(0xFFFC9039),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.213),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 17.872,
                              height: 25.532 / 17.872,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                          const SizedBox(width: 10.213),
                          Text(
                            '($reviewCount avaliações)',
                            style: const TextStyle(
                              fontSize: 17.872,
                              height: 25.532 / 17.872,
                              color: Color(0xFF6A7282),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.846),
            SizedBox(
              height: 102,
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 17.872,
                  height: 25.532 / 17.872,
                  color: Color(0xFF364153),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.menu_book_outlined, size: 17.872, color: Color(0xFF4A5565)),
                const SizedBox(width: 5.106),
                Text(
                  lessonsText,
                  style: const TextStyle(
                    fontSize: 15.319,
                    height: 20.426 / 15.319,
                    color: Color(0xFF4A5565),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.846),
            Container(height: 1, width: double.infinity, color: const Color(0xFFE5E7EB)),
            const SizedBox(height: 20.846),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: tags
                  .take(3)
                  .map(
                    (t) => Container(
                      height: 30.638,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12.766),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.38),
                        child: Text(
                          t,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15.319,
                            height: 20.426 / 15.319,
                            color: Color(0xFF364153),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 25.532),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '$pricePerHour€',
                      style: const TextStyle(
                        fontSize: 30.638,
                        height: 40.851 / 30.638,
                        fontWeight: FontWeight.w700,
                        color: _orange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/hora',
                      style: TextStyle(
                        fontSize: 17.872,
                        height: 25.532 / 17.872,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 130.023,
                      height: 53.617,
                      decoration: BoxDecoration(
                        border: Border.all(color: _orange, width: 1.277),
                        borderRadius: BorderRadius.circular(12.766),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onViewProfileTap,
                          borderRadius: BorderRadius.circular(12.766),
                          child: const Center(
                            child: Text(
                              'Ver Perfil',
                              style: TextStyle(
                                fontSize: 20.426,
                                height: 30.638 / 20.426,
                                fontWeight: FontWeight.w500,
                                color: _orange,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.213),
                    Container(
                      width: 153.65,
                      height: 53.617,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                        ),
                        borderRadius: BorderRadius.circular(12.766),
                      ),
                      child: const Center(
                        child: Text(
                          'Marcar Aula',
                          style: TextStyle(
                            fontSize: 20.426,
                            height: 30.638 / 20.426,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
