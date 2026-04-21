import 'package:flutter/material.dart';

import 'package:aula_extra/features/tutor_profile_view/constants/tutor_profile_layout.dart';

class BulletRow extends StatelessWidget {
  const BulletRow({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= kTutorProfileMobileBreakpoint;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: isMobile ? 2 : 0),
          child: Icon(
            icon,
            size: isMobile ? 20 : 25.532,
            color: const Color(0xFF0A0A0A),
          ),
        ),
        SizedBox(width: isMobile ? 12 : 15.319),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 15 : 20.426,
              height: isMobile ? 1.55 : 30.638 / 20.426,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF364153),
            ),
          ),
        ),
      ],
    );
  }
}
