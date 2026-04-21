import 'dart:ui';

import 'package:flutter/material.dart';

class BecomeTeacherAssets {
  const BecomeTeacherAssets._();

  static const heroImage = 'lib/features/register/images/hero_image.jpg';
}

class BecomeTeacherLayout {
  const BecomeTeacherLayout._();

  static const double topSpacerHeight = 54;
  static const double maxContentWidth = 1404;
  static const double contentWidth = 1404;
  static const double leftSpacerWidth = 233;
  static const double cardHeroGap = 52;
  static const double beforeFooterGap = 16;
  static const double cardWidth = 428;
  static const double cardRadius = 20.063;
  static const double cardShadowBlur = 41.797;
  static const double cardShadowSpread = -10.031;
  static const double cardShadowOffsetY = 20.898;
  static const double tabsHeight = 50.992;
  static const double tabsBottomBorderWidth = 0.836;
  static const double tabsCornerRadius = 20;
  static const double tabFontSize = 15.047;
  static const double tabLineHeight = 23.406;
  static const double tabLetterSpacing = -0.3674;
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(
    26.75,
    26.75,
    26.75,
    22,
  );
  static const double formTitleFontSize = 25.078;
  static const double formTitleLineHeight = 30.094;
  static const double formTitleLetterSpacing = 0.3306;
  static const double titleSubtitleGap = 6.688;
  static const double subtitleFontSize = 13.375;
  static const double subtitleLineHeight = 20.063;
  static const double subtitleLetterSpacing = -0.2612;
  static const EdgeInsets sectionTitlePadding = EdgeInsets.only(top: 18);
  static const double sectionTitleFontSize = 13.375;
  static const double fieldGap = 12;
  static const double fieldLabelFontSize = 11.703;
  static const double fieldLabelLineHeight = 16.719;
  static const double fieldLabelLetterSpacing = -0.1257;
  static const double labelFieldGap = 6.688;
  static const double inputHeight = 43.469;
  static const double inputRadius = 11.703;
  static const double inputBorderWidth = 1.672;
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: 13.375,
    vertical: 10.031,
  );
  static const EdgeInsetsGeometry prefixPadding = EdgeInsetsDirectional.only(
    start: 13.375,
    end: 10,
  );
  static const BoxConstraints prefixConstraints = BoxConstraints.tightFor(
    width: 40.125,
    height: 43.469,
  );
  static const double inputIconSize = 16.719;
  static const BoxConstraints passwordSuffixConstraints =
      BoxConstraints.tightFor(width: 32, height: 32);
  static const double certificateNameRemoveGap = 8;
  static const double certificateNameLinkGap = 8;
  static const double beforeSubmitGap = 18;
  static const double submitHeight = 50.156;
  static const double submitRadius = 11.703;
  static const double submitFontSize = 15.047;
  static const double submitLineHeight = 23.406;
  static const double submitLetterSpacing = -0.3674;
}

class BecomeTeacherColors {
  const BecomeTeacherColors._();

  static const Color pageBackground = Colors.white;
  static const Color inactiveTabBackground = Color(0xFFF9FAFB);
  static const Color tabsDivider = Color(0xFFE5E7EB);
  static const Color fieldLabel = Color(0xFF364153);
  static const Color hintText = Color.fromRGBO(10, 10, 10, 0.5);
  static const Color inputIconMuted = Color(0xFF99A1AF);
  static const Color removeIcon = Color(0xFF6A7282);
  static const Color submitDisabledBackground = Color(0xFFD1D5DC);
  static const Color submitDisabledText = Color(0xFF6A7282);
}

class BecomeTeacherMobileLayout {
  const BecomeTeacherMobileLayout._();

  static const double maxWidth = 341;
  static const double formWidth = 341;
  static const double sectionSpacing = 28;
  static const double heroCardRadius = 24;
  static const Gradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF7F2)],
  );
  static const Gradient actionGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
  );
  static const BoxShadow surfaceShadow = BoxShadow(
    color: Color.fromRGBO(15, 23, 42, 0.10),
    blurRadius: 24,
    spreadRadius: -8,
    offset: Offset(0, 16),
  );
  static ImageFilter get heroBlur => ImageFilter.blur(sigmaX: 16, sigmaY: 16);
}
