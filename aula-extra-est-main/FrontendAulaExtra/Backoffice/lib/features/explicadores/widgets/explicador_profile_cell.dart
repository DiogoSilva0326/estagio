import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class ExplicadorProfileCell extends StatelessWidget {
  const ExplicadorProfileCell({
    required this.initials,
    required this.name,
    required this.email,
    super.key,
  });

  final String initials;
  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46.592,
          height: 46.592,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFC9039), Color(0xFFFFBDC0)],
            ),
          ),
          child: Text(
            initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.637,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.36,
            ),
          ),
        ),
        const SizedBox(width: 13.978),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 16.307,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1752,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                email,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.978,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
