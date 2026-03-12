import 'package:aula_extra/core/components/footer/assets/footer_assets.dart';
import 'package:aula_extra/core/components/footer/constants/footer_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FooterContactsBlock extends StatelessWidget {
  const FooterContactsBlock({
    super.key,
    required this.scale,
  });

  final double scale;
  double s(double v) => v * scale;

  Widget _svgIcon(String asset, {double size = 24}) {
    return SizedBox(
      width: s(size),
      height: s(size),
      child: SvgPicture.asset(
        asset,
        fit: BoxFit.contain,
        colorFilter: const ColorFilter.mode(
          FooterColors.textColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: s(16),
      height: 1.4,
      fontWeight: FontWeight.w600,
      color: FooterColors.textColor,
    );

    final itemStyle = TextStyle(
      fontSize: s(16),
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: FooterColors.textColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: s(4)),
          child: Text('CONTACTOS', style: titleStyle),
        ),
        SizedBox(height: s(14)),
        Row(
          children: [
            _svgIcon(FooterAssets.mail),
            SizedBox(width: s(6)),
            Expanded(
              child: Text('info@aulaextra.pt', style: itemStyle, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        SizedBox(height: s(10)),
        Row(
          children: [
            _svgIcon(FooterAssets.phone),
            SizedBox(width: s(6)),
            Expanded(
              child: Text('+351 914 359 786', style: itemStyle, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        SizedBox(height: s(22)),
        Row(
          children: [
            _svgIcon(FooterAssets.instagram, size: 20),
            SizedBox(width: s(12)),
            _svgIcon(FooterAssets.facebook, size: 20),
          ],
        ),
      ],
    );
  }
}
