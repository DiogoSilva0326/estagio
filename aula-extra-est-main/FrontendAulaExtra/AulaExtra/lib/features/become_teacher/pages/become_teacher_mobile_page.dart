import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/become_teacher/assets/become_teacher_assets.dart';
import 'package:aula_extra/features/become_teacher/widgets/become_teacher_card.dart';
import 'package:aula_extra/features/become_teacher/widgets/become_teacher_mobile_hero_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class BecomeTeacherMobilePage extends StatelessWidget {
  const BecomeTeacherMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: BecomeTeacherMobileLayout.pageGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AppHeader(
                onRegisterTap: () => Navigator.pushReplacementNamed(
                  context,
                  Routes.registerStudent,
                ),
                onLoginTap: () =>
                    Navigator.pushReplacementNamed(context, Routes.login),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: BecomeTeacherMobileLayout.sectionSpacing,
                      ),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: BecomeTeacherMobileLayout.maxWidth,
                          ),
                          child: Column(
                            children: [
                              BecomeTeacherCard(
                                onLoginTap: () =>
                                    Navigator.pushReplacementNamed(
                                      context,
                                      Routes.login,
                                    ),
                                width: BecomeTeacherMobileLayout.formWidth,
                                compact: true,
                              ),
                              const SizedBox(
                                height:
                                    BecomeTeacherMobileLayout.sectionSpacing,
                              ),
                              const BecomeTeacherMobileHeroSection(),
                              const SizedBox(
                                height:
                                    BecomeTeacherMobileLayout.sectionSpacing,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const FooterSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
