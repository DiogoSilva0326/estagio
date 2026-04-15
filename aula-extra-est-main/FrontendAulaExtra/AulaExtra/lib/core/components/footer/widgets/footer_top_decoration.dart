import 'package:aula_extra/core/components/footer/assets/footer_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FooterTopDecoration extends StatelessWidget {
  const FooterTopDecoration({
    super.key,
    required this.scale,
    this.compactMobile = false,
  });

  final double scale;
  final bool compactMobile;
  double s(double v) => v * scale;

  Widget _buildSymbol({
    required double width,
    required double height,
    double horizontalPadding = 0,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SvgPicture.asset(
            FooterAssets.topGroup,
            height: height,
            fit: BoxFit.fitHeight,
            alignment: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (compactMobile) {
          final containerWidth = constraints.maxWidth;
          final symbolWidth = (containerWidth / 4.6).clamp(64.0, 88.0);
          final symbolHeight = s(66);
          final innerGap = ((containerWidth - (symbolWidth * 4)) / 3)
              .clamp(0.0, containerWidth)
              .toDouble();

          return SizedBox(
            width: containerWidth,
            height: symbolHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: _buildSymbol(width: symbolWidth, height: symbolHeight),
                ),
                Positioned(
                  left: symbolWidth + innerGap,
                  bottom: 0,
                  child: _buildSymbol(width: symbolWidth, height: symbolHeight),
                ),
                Positioned(
                  left: (symbolWidth * 2) + (innerGap * 2),
                  bottom: 0,
                  child: _buildSymbol(width: symbolWidth, height: symbolHeight),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildSymbol(width: symbolWidth, height: symbolHeight),
                ),
              ],
            ),
          );
        }

        final itemWidth = constraints.maxWidth / 11;
        final availableHeight = constraints.maxHeight > 0
            ? constraints.maxHeight
            : s(74);
        final symbolHeight = availableHeight.clamp(s(58), s(74)).toDouble();

        return SizedBox(
          width: constraints.maxWidth,
          height: symbolHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: 0,
                left: -itemWidth / 2,
                right: -itemWidth / 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(12, (_) {
                    return _buildSymbol(
                      width: itemWidth,
                      height: symbolHeight,
                      horizontalPadding: s(4),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
