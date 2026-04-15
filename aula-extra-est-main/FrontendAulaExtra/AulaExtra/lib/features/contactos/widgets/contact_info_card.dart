import 'package:flutter/material.dart';

class ContactInfoCard extends StatelessWidget {
  const ContactInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
  });

  final String title;
  final String value;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 645.26,
      padding: const EdgeInsets.all(31.142),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24.913),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24.913,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12.457),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19.931,
              height: 1.5,
              fontWeight: FontWeight.w400,
              color: Color(0xB3000000),
            ),
          ),
        ],
      ),
    );
  }
}
