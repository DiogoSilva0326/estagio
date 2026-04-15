import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/login/pages/login_mobile_page.dart';
import 'package:aula_extra/features/login/widgets/hero_panel.dart';
import 'package:aula_extra/features/login/widgets/login_card.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;
    if (isMobile) {
      return const LoginMobilePage();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: PinnedHeaderDelegate(
              height: AppHeader.resolvedHeight(context),
              child: AppHeader(
                onRegisterTap: () => Navigator.pushReplacementNamed(
                  context,
                  Routes.registerStudent,
                ),
                onLoginTap: () =>
                    Navigator.pushReplacementNamed(context, Routes.login),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 54),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1404),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: 1404,
                        height: 686,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 233),
                            LoginCard(
                              onRegisterTap: () =>
                                  Navigator.pushReplacementNamed(
                                    context,
                                    Routes.registerStudent,
                                  ),
                            ),
                            const SizedBox(width: 52),
                            const LoginHeroPanel(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const FooterSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
