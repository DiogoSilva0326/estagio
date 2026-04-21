import 'package:aula_extra/core/components/footer/sections/footer_desktop_section.dart';
import 'package:aula_extra/core/navigation/become_teacher_navigation.dart';
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

  Map<String, VoidCallback> _footerActions(BuildContext context) {
    void scrollToTop() {
      final controller = PrimaryScrollController.maybeOf(context);
      if (controller != null && controller.hasClients) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
        return;
      }

      final scrollableState = Scrollable.maybeOf(context);
      final position = scrollableState?.position;
      if (position != null && position.hasPixels) {
        position.animateTo(
          0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    }

    void onFindTutorTap() {
      final currentRouteName = ModalRoute.of(context)?.settings.name;

      if (currentRouteName == Routes.explicadores) {
        scrollToTop();
        return;
      }

      Navigator.of(context).pushNamed(Routes.explicadores);
    }

    void onComoFuncionaTap() {
      final currentRouteName = ModalRoute.of(context)?.settings.name;

      if (currentRouteName == Routes.home) {
        scrollToTop();
        return;
      }

      Navigator.of(context).pushNamed(Routes.home);
    }

    void onFaqTap() {
      final currentRouteName = ModalRoute.of(context)?.settings.name;

      if (currentRouteName == Routes.faq) {
        scrollToTop();
        return;
      }

      Navigator.of(context).pushNamed(Routes.faq);
    }

    void onPricingTap() {
      final currentRouteName = ModalRoute.of(context)?.settings.name;

      if (currentRouteName == Routes.comprarCreditos) {
        scrollToTop();
        return;
      }

      Navigator.of(context).pushNamed(Routes.comprarCreditos);
    }

    void onBecomeTeacherTap() {
      final currentRouteName = ModalRoute.of(context)?.settings.name;

      if (currentRouteName == Routes.becomeTeacher) {
        scrollToTop();
        return;
      }

      navigateToBecomeTeacherFlow(context);
    }

    return <String, VoidCallback>{
      'Preços': onPricingTap,
      'Encontrar Explicador': onFindTutorTap,
      'Como Funciona': onComoFuncionaTap,
      'Tornar-se Explicador': onBecomeTeacherTap,
      'FAQ': onFaqTap,
    };
  }

  Widget _buildScaledDesktopBody(
    BuildContext context,
    BoxConstraints constraints, {
    required bool useDesktopFooter,
  }) {
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

    const quickLinkItems = [
      'Como Funciona',
      'Preços',
      'Encontrar Explicador',
      'Tornar-se Explicador',
      'FAQ',
    ];

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: PinnedHeaderDelegate(
            height: AppHeader.resolvedHeight(context),
            child: AppHeader(
              onRegisterTap: () =>
                  Navigator.of(context).pushNamed(Routes.registerStudent),
              onLoginTap: () => Navigator.of(context).pushNamed(Routes.login),
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
                  child: FullBleedScaledSection(child: AreasPopularesSection()),
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
                  child: FullBleedScaledSection(child: RatingsBannerSection()),
                ),
              ),
              scaled(const ComoFuncionaSection()),
              const ColoredBox(
                color: Color(0xFFF9F9F9),
                child: SizedBox(
                  width: double.infinity,
                  child: FullBleedScaledSection(child: ExplicadoresSection()),
                ),
              ),
              const ColoredBox(
                color: Color(0xFFF9F9F9),
                child: SizedBox(
                  width: double.infinity,
                  child: FullBleedScaledSection(child: CtaSection()),
                ),
              ),
              ColoredBox(
                color: const Color(0xFFF9F9F9),
                child: useDesktopFooter
                    ? FooterDesktopSection(
                        quickLinkItems: quickLinkItems,
                        onTapByItem: _footerActions(context),
                      )
                    : const FooterSection(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<UserProvider>().role;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCompactMobile =
              constraints.maxWidth <= kHomeCompactMobileBreakpoint;
          final isTabletHybrid = constraints.maxWidth <= kHomeMobileBreakpoint;

          if (isCompactMobile) {
            return const HomeMobilePage();
          }

          if (isTabletHybrid) {
            return _buildScaledDesktopBody(
              context,
              constraints,
              useDesktopFooter: true,
            );
          }

          return _buildScaledDesktopBody(
            context,
            constraints,
            useDesktopFooter: false,
          );
        },
      ),
    );
  }
}
