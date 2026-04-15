import 'package:aula_extra/features/register/assets/register_assets.dart';
import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:flutter/material.dart';

class RegisterSocial {
  static const order = ['google', 'facebook', 'apple'];

  static const labels = {
    'google': 'Google',
    'facebook': 'Facebook',
    'apple': 'Apple',
  };

  static const assets = {
    'google': RegisterAssets.google,
    'facebook': RegisterAssets.facebook,
    'apple': RegisterAssets.apple,
  };

  static const backgroundColors = {
    'google': Colors.white,
    'facebook': Color(0xFF1877F2),
    'apple': Colors.black,
  };

  static const borderColors = {
    'google': RegisterColors.stroke,
    'facebook': Colors.transparent,
    'apple': Colors.transparent,
  };

  static const textColors = {
    'google': Color(0xFF364153),
    'facebook': Colors.white,
    'apple': Colors.white,
  };
}
