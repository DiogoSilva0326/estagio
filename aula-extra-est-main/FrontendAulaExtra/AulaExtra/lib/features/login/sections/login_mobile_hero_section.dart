import 'dart:ui';

import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/login/assets/login_assets.dart';
import 'package:aula_extra/features/login/constants/login_mobile_layout.dart';
import 'package:aula_extra/features/login/widgets/login_mobile_stat_card.dart';
import 'package:flutter/material.dart';

class LoginMobileHeroSection extends StatelessWidget {
  const LoginMobileHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: LoginMobileLayout.cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: LoginMobileStatCard(
              width: 193,
              value: '5000+',
              label: 'Estudantes',
              circleGradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF8904), Color(0xFFFF6467)],
              ),
              icon: const Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 256,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color.fromRGBO(255, 137, 4, 0.2),
                              Color.fromRGBO(255, 100, 103, 0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: const AssetPicture(
                      LoginAssets.heroImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: LoginMobileStatCard(
              width: 160,
              value: '98%',
              label: 'Satisfação',
              circleColor: Color(0xFF00C950),
              icon: Icon(Icons.check_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}
