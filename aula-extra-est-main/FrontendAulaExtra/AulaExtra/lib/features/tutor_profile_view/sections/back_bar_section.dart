import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

import 'package:aula_extra/features/tutor_profile_view/constants/tutor_profile_layout.dart';

class BackBarSection extends StatelessWidget {
  const BackBarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= kTutorProfileMobileBreakpoint;

    return Container(
      height: isMobile ? 60 : 72.766,
      padding: EdgeInsets.only(
        left: isMobile ? 16 : 40.851,
        right: isMobile ? 16 : 0,
        top: isMobile ? 10 : 20.426,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.277),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.766),
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return;
            }
            Navigator.of(context).pushNamed(Routes.explicadores);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 6 : 10.213,
              vertical: isMobile ? 8 : 5.106,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back,
                  size: isMobile ? 20 : 25.532,
                  color: const Color(0xFF4A5565),
                ),
                SizedBox(width: isMobile ? 8 : 10.213),
                Text(
                  'Voltar aos Explicadores',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 20.426,
                    height: isMobile ? 1.35 : 30.638 / 20.426,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4A5565),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
