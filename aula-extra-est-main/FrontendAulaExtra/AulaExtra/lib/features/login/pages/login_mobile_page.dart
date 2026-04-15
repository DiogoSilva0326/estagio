import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/login/constants/login_mobile_layout.dart';
import 'package:aula_extra/features/login/sections/login_mobile_form_section.dart';
import 'package:aula_extra/features/login/sections/login_mobile_hero_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class LoginMobilePage extends StatelessWidget {
  const LoginMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LoginMobileLayout.pageGradient,
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
                      const SizedBox(height: LoginMobileLayout.sectionSpacing),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: LoginMobileLayout.maxWidth,
                          ),
                          child: const Column(
                            children: [LoginMobileFormSectionPlaceholder()],
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

class LoginMobileFormSectionPlaceholder extends StatelessWidget {
  const LoginMobileFormSectionPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoginMobileFormSection(
          onRegisterTap: () =>
              Navigator.pushReplacementNamed(context, Routes.registerStudent),
        ),
        SizedBox(height: LoginMobileLayout.sectionSpacing),
        const LoginMobileHeroSection(),
        const SizedBox(height: LoginMobileLayout.sectionSpacing),
      ],
    );
  }
}
