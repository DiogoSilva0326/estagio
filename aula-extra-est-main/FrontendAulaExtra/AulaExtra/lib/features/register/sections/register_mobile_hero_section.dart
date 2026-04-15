import 'dart:ui';

import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/register/assets/register_assets.dart';
import 'package:aula_extra/features/register/widgets/register_mobile_stat_card.dart';
import 'package:flutter/material.dart';

class RegisterMobileHeroSection extends StatelessWidget {
  const RegisterMobileHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 341,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: RegisterMobileStatCard(
              width: 193,
              value: '5000+',
              label: 'Estudantes',
              circleGradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: const AssetPicture(
                      RegisterAssets.heroImage,
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
            child: RegisterMobileStatCard(
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
