import 'package:flutter/material.dart';

import 'package:aula_extra/features/tutor_profile_view/constants/tutor_profile_layout.dart';

class SectionContainer extends StatelessWidget {
  const SectionContainer({
    super.key,
    required this.title,
    required this.child,
    this.leadingIcon,
  });

  final String title;
  final Widget child;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= kTutorProfileMobileBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: isMobile ? 22 : 30.638,
                color: const Color(0xFF0A0A0A),
              ),
              SizedBox(width: isMobile ? 8 : 10.213),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 25.532,
                  height: isMobile ? 1.3 : 35.745 / 25.532,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0A0A0A),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 12 : 15.319),
        child,
      ],
    );
  }
}
