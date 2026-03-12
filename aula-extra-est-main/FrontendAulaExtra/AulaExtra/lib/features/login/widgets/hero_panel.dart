import 'dart:ui';

import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/login/assets/login_assets.dart';
import 'package:aula_extra/features/login/constants/login_colors.dart';
import 'package:flutter/material.dart';

class LoginHeroPanel extends StatelessWidget {
  const LoginHeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 639.518,
      height: 360.02,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(57.701),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 38.467, sigmaY: 38.467),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromRGBO(252, 144, 57, 0.2),
                        Color.fromRGBO(241, 92, 100, 0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(57.701),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    blurRadius: 60.105,
                    spreadRadius: -14.425,
                    offset: Offset(0, 30.053),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(57.701),
                child: const AssetPicture(LoginAssets.heroImage, fit: BoxFit.cover),
              ),
            ),
          ),
          const Positioned(
            right: -27,
            top: 33,
            child: _StatCard(
              background: Colors.white,
              circleGradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [LoginColors.gradientStart, LoginColors.gradientEnd],
              ),
              icon: Icon(Icons.groups_rounded, color: Colors.white, size: 22),
              value: '5000+',
              label: 'Estudantes',
            ),
          ),
          const Positioned(
            left: -29,
            bottom: 48,
            child: _StatCard(
              background: Colors.white,
              circleColor: Color(0xFF00C950),
              icon: Icon(Icons.check_rounded, color: Colors.white, size: 22),
              value: '98%',
              label: 'Satisfação',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.background,
    required this.icon,
    required this.value,
    required this.label,
    this.circleGradient,
    this.circleColor,
  });

  final Color background;
  final Widget icon;
  final String value;
  final String label;
  final LinearGradient? circleGradient;
  final Color? circleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 186.495,
      height: 96.168,
      padding: const EdgeInsets.fromLTRB(19.234, 19.234, 19.234, 0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(19.234),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 30.053,
            offset: Offset(0, 24.042),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 12.021,
            offset: Offset(0, 9.617),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 57.701,
            height: 57.701,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
              gradient: circleGradient,
            ),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: 14.425),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 19.234,
                  fontWeight: FontWeight.w700,
                  color: LoginColors.textPrimary,
                  height: 28.85 / 19.234,
                  letterSpacing: -0.3757,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14.425,
                  fontWeight: FontWeight.w400,
                  color: LoginColors.textSecondary,
                  height: 19.234 / 14.425,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
