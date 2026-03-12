import 'package:aula_extra/core/components/footer/assets/footer_assets.dart';
import 'package:aula_extra/core/components/footer/constants/footer_colors.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_contacts_block.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_text_link_list.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_top_decoration.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  static const double _baseWidth = 1539;
  static const double _baseHeight = 390;

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

    void onBecomeTeacherTap() {
      final currentRouteName = ModalRoute.of(context)?.settings.name;

      if (currentRouteName == Routes.becomeTeacher) {
        scrollToTop();
        return;
      }

      final user = context.read<UserProvider>();
      if (!user.isLoggedIn) {
        Navigator.of(context).pushNamed(Routes.registerStudent);
        return;
      }

      Navigator.of(context).pushNamed(Routes.becomeTeacher);
    }

    return SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : _baseWidth;
          final scale = maxWidth / _baseWidth;
          final height = _baseHeight * scale;
          double s(double v) => v * scale;

          return SizedBox(
            width: maxWidth,
            height: height,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: height * 0.0026,
                  height: height * (1 - 0.8051 - 0.0026),
                  child: FooterTopDecoration(scale: scale),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: s(74),
                  bottom: 0,
                  child: ClipRect(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [FooterColors.gradientStart, FooterColors.gradientEnd],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: s(48)),
                        child: Stack(
                          children: [
                            Positioned(
                              left: s(45),
                              top: s(39),
                              width: s(273),
                              height: s(68),
                              child: Image.asset(
                                FooterAssets.logo,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              left: s(391),
                              top: s(58),
                              child: FooterTextLinkList(
                                title: 'LINKS RÁPIDOS',
                                items: const [
                                  'Como Funciona',
                                  'Preços',
                                  'Encontrar Explicador',
                                  'Tornar-se Explicador',
                                  'FAQ',
                                ],
                                onTapByItem: {
                                  'Encontrar Explicador': onFindTutorTap,
                                  'Como Funciona': onComoFuncionaTap,
                                  'Tornar-se Explicador': onBecomeTeacherTap,
                                  'FAQ': onFaqTap,
                                },
                                scale: scale,
                              ),
                            ),
                            Positioned(
                              left: s(600),
                              top: s(56),
                              width: s(262),
                              height: s(176),
                              child: FooterContactsBlock(scale: scale),
                            ),
                            Positioned(
                              left: s(1178),
                              top: s(56),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NEWSLETTER',
                                    style: TextStyle(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: FooterColors.textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    const [
                                      'Subscreve para',
                                      'receber atualizações',
                                      'sobre novos explicadores',
                                      'e ofertas especiais',
                                    ].join('\n'),
                                    style: TextStyle(
                                      fontSize: 14 * scale,
                                      fontWeight: FontWeight.w400,
                                      color: FooterColors.textColor,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
