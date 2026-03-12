import 'package:flutter/material.dart';

class ProfileSummarySection extends StatelessWidget {
  const ProfileSummarySection({
    super.key,
    required this.name,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.lessonsText,
    required this.pricePerHour,
    required this.tags,
  });

  final String name;
  final String country;
  final double rating;
  final int reviewCount;
  final String lessonsText;
  final int pricePerHour;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final filledStars = rating.floor().clamp(0, 5);

    return SizedBox(
      height: 311.489,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 40.851, right: 40.851, top: 122.553),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 45.957,
                          height: 51.064 / 45.957,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      const SizedBox(width: 20),
                      if (tags.isNotEmpty)
                        Container(
                          height: 35.745,
                          padding: const EdgeInsets.symmetric(horizontal: 15.319),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.all(Radius.circular(21417702)),
                          ),
                          child: Center(
                            child: Text(
                              tags.first,
                              style: const TextStyle(
                                fontSize: 17.872,
                                height: 25.532 / 17.872,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1447E6),
                              ),
                            ),
                          ),
                        ),
                      if (tags.length > 1) ...[
                        const SizedBox(width: 10.213),
                        Container(
                          height: 35.745,
                          padding: const EdgeInsets.symmetric(horizontal: 15.319),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(21417702)),
                          ),
                          child: Center(
                            child: Text(
                              tags[1],
                              style: const TextStyle(
                                fontSize: 17.872,
                                height: 25.532 / 17.872,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10.213),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 22.979, color: Color(0xFF4A5565)),
                      const SizedBox(width: 5.106),
                      Text(
                        country,
                        style: const TextStyle(
                          fontSize: 20.426,
                          height: 30.638 / 20.426,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A5565),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.426),
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < filledStars ? Icons.star : Icons.star_border,
                            size: 25.532,
                            color: const Color(0xFFFC9039),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.213),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 22.979,
                          height: 35.745 / 22.979,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      const SizedBox(width: 10.213),
                      Text(
                        '($reviewCount avaliações)',
                        style: const TextStyle(
                          fontSize: 20.426,
                          height: 30.638 / 20.426,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                      const SizedBox(width: 30.638),
                      const Icon(Icons.school_outlined, size: 25.532, color: Color(0xFF4A5565)),
                      const SizedBox(width: 10.213),
                      Text(
                        lessonsText,
                        style: const TextStyle(
                          fontSize: 20.426,
                          height: 30.638 / 20.426,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A5565),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 169.977),
              child: Align(
                alignment: Alignment.topRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$pricePerHour€',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 61.277,
                          height: 61.277 / 61.277,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFC9039),
                        ),
                      ),
                      const SizedBox(height: 5.106),
                      const Text(
                        'por hora',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 20.426,
                          height: 30.638 / 20.426,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                    ],
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
