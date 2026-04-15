import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/home/constants/home_layout.dart';
import 'package:aula_extra/features/home/pages/home_mobile_page.dart';
import 'package:aula_extra/features/home/sections/areas_populares_section.dart';
import 'package:aula_extra/features/home/sections/como_funciona_section.dart';
import 'package:aula_extra/features/home/sections/cta_section.dart';
import 'package:aula_extra/features/home/sections/explicadores_section.dart';
import 'package:aula_extra/features/home/sections/hero_section.dart';
import 'package:aula_extra/features/home/sections/ratings_banner_section.dart';
import 'package:aula_extra/features/home/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRole = context.watch<UserProvider>().role;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth <= kHomeMobileBreakpoint;
          if (isMobile) {
            return const HomeMobilePage();
          }

          Widget scaled(Widget child) {
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(width: kHomeDesignWidth, child: child),
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: PinnedHeaderDelegate(
                  height: userRole == Role.none
                      ? AppHeader.height
                      : AppHeader.height,
                  child: AppHeader(
                    onRegisterTap: () =>
                        Navigator.of(context).pushNamed(Routes.registerStudent),
                    onLoginTap: () =>
                        Navigator.of(context).pushNamed(Routes.login),
                    onLogoTap: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(Routes.home, (route) => false),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    scaled(const HeroSection()),
                    const ColoredBox(
                      color: Color(0xFFF9F9F9),
                      child: SizedBox(
                        width: double.infinity,
                        child: FullBleedScaledSection(
                          child: AreasPopularesSection(),
                        ),
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: FullBleedScaledSection(
                          child: RatingsBannerSection(),
                        ),
                      ),
                    ),
                    scaled(const ComoFuncionaSection()),
                    const ColoredBox(
                      color: Color(0xFFF9F9F9),
                      child: SizedBox(
                        width: double.infinity,
                        child: FullBleedScaledSection(
                          child: ExplicadoresSection(),
                        ),
                      ),
                    ),
                    const ColoredBox(
                      color: Color(0xFFF9F9F9),
                      child: SizedBox(
                        width: double.infinity,
                        child: FullBleedScaledSection(child: CtaSection()),
                      ),
                    ),
                    const ColoredBox(
                      color: Color(0xFFF9F9F9),
                      child: FooterSection(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
