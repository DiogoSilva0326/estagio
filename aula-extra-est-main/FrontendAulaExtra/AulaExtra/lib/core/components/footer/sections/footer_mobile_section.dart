import 'package:aula_extra/core/components/footer/assets/footer_assets.dart';
import 'package:aula_extra/core/components/footer/constants/footer_colors.dart';
import 'package:aula_extra/core/components/footer/constants/footer_layout.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_contacts_block.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_legal_block.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_newsletter_block.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_text_link_list.dart';
import 'package:aula_extra/core/components/footer/widgets/footer_top_decoration.dart';
import 'package:flutter/material.dart';

class FooterMobileSection extends StatelessWidget {
  const FooterMobileSection({
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
              : MediaQuery.sizeOf(context).width;
          final scale = (maxWidth / FooterLayout.mobileBaseWidth)
              .clamp(0.92, 1.18)
              .toDouble();
          final contentScale = scale * 0.84;

          double s(double value) => value * scale;
          final decorationHeight = s(72);
          final footerTopOffset = decorationHeight - s(1);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: SizedBox(
                  height: decorationHeight,
                  child: FooterTopDecoration(scale: scale, compactMobile: true),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: footerTopOffset),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        FooterColors.gradientStart,
                        FooterColors.gradientEnd,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(s(28), s(54), s(28), s(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            FooterAssets.logo,
                            width: s(136),
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: s(26)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FooterTextLinkList(
                                title: 'LINKS RÁPIDOS',
                                items: quickLinkItems,
                                onTapByItem: onTapByItem,
                                scale: contentScale,
                              ),
                            ),
                            SizedBox(width: s(16)),
                            Expanded(
                              child: FooterContactsBlock(scale: contentScale),
                            ),
                          ],
                        ),
                        SizedBox(height: s(28)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FooterNewsletterBlock(scale: contentScale),
                            ),
                            SizedBox(width: s(16)),
                            Expanded(
                              child: FooterLegalBlock(scale: contentScale),
                            ),
                          ],
                        ),
                        SizedBox(height: s(24)),
                        Divider(
                          height: s(1),
                          thickness: 1,
                          color: const Color(0x33000000),
                        ),
                        SizedBox(height: s(16)),
                        Text(
                          '© 2026 Aula Extra. Todos os direitos reservados.',
                          style: TextStyle(
                            fontSize: s(10.5),
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                            color: FooterColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
