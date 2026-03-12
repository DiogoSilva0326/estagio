import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetPicture extends StatelessWidget {
  const AssetPicture(
    this.asset, {
    super.key,
    this.fit,
    this.width,
    this.height,
  });

  final String asset;
  final BoxFit? fit;
  final double? width;
  final double? height;

  bool get _isSvg => asset.toLowerCase().endsWith('.svg');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return SvgPicture.asset(
        asset,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
      );
    }

    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit ?? BoxFit.contain,
    );
  }
}
