import 'package:flutter/material.dart';

import 'package:aula_extra/features/tutor_profile_view/constants/tutor_profile_layout.dart';

class ProfileSummarySection extends StatelessWidget {
  const ProfileSummarySection({
    super.key,
    required this.name,
    this.photoUrl,
    this.isVerified = false,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.lessonsText,
    required this.pricePerHour,
    required this.tags,
  });

  final String name;
  final String? photoUrl;
  final bool isVerified;
  final String country;
  final double rating;
  final int reviewCount;
  final String lessonsText;
  final int pricePerHour;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    final filledStars = rating.floor().clamp(0, 5);
    final isMobile =
        MediaQuery.sizeOf(context).width <= kTutorProfileMobileBreakpoint;

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: const Color(0xFFF3F4F6),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.12),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: photoUrl?.trim().isNotEmpty == true
                        ? Image.network(
                            photoUrl!.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Icon(
                                    Icons.person,
                                    size: 38,
                                    color: Color(0xFF6A7282),
                                  ),
                                ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.person,
                              size: 38,
                              color: Color(0xFF6A7282),
                            ),
                          ),
                  ),
                ),
                if (isVerified)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < tags.length && index < 2; index++)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: index == 0 ? const Color(0xFFDBEAFE) : null,
                      gradient: index == 1
                          ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                            )
                          : null,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(999),
                      ),
                    ),
                    child: Text(
                      tags[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: index == 0
                            ? const Color(0xFF1447E6)
                            : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: Color(0xFF6A7282),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    country,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4A5565),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < filledStars ? Icons.star : Icons.star_border,
                          size: 18,
                          color: const Color(0xFFFC9039),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($reviewCount avaliações)',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 17,
                      color: Color(0xFF4A5565),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      lessonsText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF364153),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 340),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(15, 23, 42, 0.08),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '$pricePerHour€',
                    style: const TextStyle(
                      fontSize: 40,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFC6900),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'por hora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4A5565),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 311.489,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 40.851,
          right: 40.851,
          top: 122.553,
        ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.319,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.all(
                              Radius.circular(21417702),
                            ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15.319,
                          ),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(21417702),
                            ),
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
                      const Icon(
                        Icons.location_on_outlined,
                        size: 22.979,
                        color: Color(0xFF4A5565),
                      ),
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
                      const Icon(
                        Icons.school_outlined,
                        size: 25.532,
                        color: Color(0xFF4A5565),
                      ),
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
