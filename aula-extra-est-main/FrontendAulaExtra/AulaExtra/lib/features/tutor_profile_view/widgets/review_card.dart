import 'package:flutter/material.dart';

import 'package:aula_extra/features/tutor_profile_view/constants/tutor_profile_layout.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.name,
    required this.when,
    required this.rating,
    required this.text,
    this.avatarUrl,
  });

  final String name;
  final String when;
  final int rating;
  final String text;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= kTutorProfileMobileBreakpoint;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 21.702,
        vertical: isMobile ? 16 : 21.702,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.766),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.277),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isMobile ? 44 : 51.064,
                    height: isMobile ? 44 : 51.064,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF3F4F6),
                    ),
                    child: ClipOval(
                      child: avatarUrl?.trim().isNotEmpty == true
                          ? Image.network(
                              avatarUrl!.trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Text(
                                      _initials(name),
                                      style: TextStyle(
                                        fontSize: isMobile ? 16 : 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                            )
                          : Center(
                              child: Text(
                                _initials(name),
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 15.319),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 20.426,
                          height: isMobile ? 1.35 : 30.638 / 20.426,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0A0A0A),
                        ),
                      ),
                      Text(
                        when,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 17.872,
                          height: isMobile ? 1.35 : 25.532 / 17.872,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6A7282),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    size: isMobile ? 16 : 17.872,
                    color: const Color(0xFFFC9039),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 10.213),
          Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 15 : 20.426,
              height: isMobile ? 1.6 : 30.638 / 20.426,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF364153),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((item) => item.isNotEmpty)
        .take(2)
        .toList(growable: false);
    if (parts.isEmpty) return 'A';
    return parts.map((item) => item.characters.first.toUpperCase()).join();
  }
}
