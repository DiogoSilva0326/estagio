import 'package:aula_extra/core/components/footer/assets/footer_assets.dart';
import 'package:aula_extra/core/components/footer/constants/footer_colors.dart';
import 'package:aula_extra/core/components/footer/constants/footer_layout.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_contacts_block.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_newsletter_block.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_text_link_list.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_top_decoration.dart';
import 'package:flutter/material.dart';

class FooterDesktopSection extends StatelessWidget {
  const FooterDesktopSection({
    super.key,
    required this.quickLinkItems,
    required this.onTapByItem,
  });

  final List<String> quickLinkItems;
  final Map<String, VoidCallback> onTapByItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : FooterLayout.desktopBaseWidth;
          final scale = maxWidth / FooterLayout.desktopBaseWidth;
          final height = FooterLayout.desktopBaseHeight * scale;

          double s(double value) => value * scale;

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
                          colors: [
                            FooterColors.gradientStart,
                            FooterColors.gradientEnd,
                          ],
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
                                items: quickLinkItems,
                                onTapByItem: onTapByItem,
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
                              child: FooterNewsletterBlock(scale: scale),
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