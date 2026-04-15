import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/register/constants/register_mobile_layout.dart';
import 'package:aula_extra/features/register/sections/register_mobile_form_section.dart';
import 'package:aula_extra/features/register/sections/register_mobile_hero_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class RegisterMobilePage extends StatelessWidget {
  const RegisterMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RegisterMobileLayout.pageGradient,
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
                        height: RegisterMobileLayout.sectionSpacing,
                      ),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: RegisterMobileLayout.maxWidth,
                          ),
                          child: const Column(
                            children: [RegisterMobileContent()],
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

class RegisterMobileContent extends StatelessWidget {
  const RegisterMobileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RegisterMobileFormSection(
          onLoginTap: () =>
              Navigator.pushReplacementNamed(context, Routes.login),
        ),
        const SizedBox(height: RegisterMobileLayout.sectionSpacing),
        const RegisterMobileHeroSection(),
        const SizedBox(height: RegisterMobileLayout.sectionSpacing),
      ],
    );
  }
}
