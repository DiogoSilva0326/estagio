import 'package:aula_extra/core/components/footer/constants/footer_layout.dart';
import 'package:aula_extra/core/navigation/become_teacher_navigation.dart';
import 'package:aula_extra/core/components/footer/sections/footer_desktop_section.dart';
import 'package:aula_extra/core/components/footer/sections/footer_mobile_section.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
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

    const quickLinkItems = [
      'Como Funciona',
      'Preços',
      'Encontrar Explicador',
      'Tornar-se Explicador',
      'FAQ',
    ];

    final onTapByItem = <String, VoidCallback>{
      'Preços': onPricingTap,
      'Encontrar Explicador': onFindTutorTap,
      'Como Funciona': onComoFuncionaTap,
      'Tornar-se Explicador': onBecomeTeacherTap,
      'FAQ': onFaqTap,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        if (width <= FooterLayout.mobileBreakpoint) {
          return FooterMobileSection(
            quickLinkItems: quickLinkItems,
            onTapByItem: onTapByItem,
          );
        }

        return FooterDesktopSection(
          quickLinkItems: quickLinkItems,
          onTapByItem: onTapByItem,
        );
      },
    );
  }
}
