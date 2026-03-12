import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.name,
    required this.when,
    required this.rating,
    required this.text,
  });

  final String name;
  final String when;
  final int rating;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 21.702, vertical: 21.702),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.766),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.277),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 51.064,
                    height: 51.064,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF3F4F6),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name.trim().characters.first : 'A',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15.319),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20.426,
                          height: 30.638 / 20.426,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      Text(
                        when,
                        style: const TextStyle(
                          fontSize: 17.872,
                          height: 25.532 / 17.872,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6A7282),
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
                    size: 17.872,
                    color: const Color(0xFFFC9039),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.213),
          Text(
            text,
            style: const TextStyle(
              fontSize: 20.426,
              height: 30.638 / 20.426,
              fontWeight: FontWeight.w400,
              color: Color(0xFF364153),
            ),
          ),
        ],
      ),
    );
  }
}
