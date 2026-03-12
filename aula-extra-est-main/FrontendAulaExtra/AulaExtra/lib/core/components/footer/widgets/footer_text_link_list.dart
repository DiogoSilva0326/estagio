import 'package:aula_extra/core/components/footer/constants/footer_colors.dart';
import 'package:flutter/material.dart';

class FooterTextLinkList extends StatelessWidget {
  const FooterTextLinkList({
    super.key,
    required this.title,
    required this.items,
    required this.scale,
    this.onTapByItem,
  });

  final String title;
  final List<String> items;
  final double scale;
  final Map<String, VoidCallback>? onTapByItem;

  double s(double v) => v * scale;

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
          child: Text(title, style: titleStyle),
        ),
        for (final item in items) ...[
          SizedBox(height: s(8)),
          Builder(
            builder: (context) {
              final onTap = onTapByItem?[item];
              if (onTap == null) return Text(item, style: itemStyle);
              return InkWell(
                onTap: onTap,
                child: Text(item, style: itemStyle),
              );
            },
          ),
        ],
      ],
    );
  }
}
