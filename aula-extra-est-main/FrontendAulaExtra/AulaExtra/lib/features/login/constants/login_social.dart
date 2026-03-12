import 'package:aula_extra/features/login/assets/login_assets.dart';
import 'package:aula_extra/features/login/constants/login_colors.dart';
import 'package:flutter/material.dart';

/// Configuração dos botões de **Login Social**.
///
/// Onde é usado:
/// - Em `lib/features/login/` para renderizar botões de autenticação social
///   (ordem, label, ícone, cores de fundo/borda/texto).
///
/// Nota:
/// - As chaves (`google`, `facebook`, `apple`) devem manter-se consistentes entre
///   `order`, `labels`, `assets` e mapas de cores.
class LoginSocial {
  /// Ordem de apresentação dos botões de login social.
  static const order = ['google', 'facebook', 'apple'];

  /// Labels por provider.
  static const labels = {
    'google': 'Google',
    'facebook': 'Facebook',
    'apple': 'Apple',
  };

  /// Assets (ícones) por provider.
  static const assets = {
    'google': LoginAssets.google,
    'facebook': LoginAssets.facebook,
    'apple': LoginAssets.apple,
  };

  /// Cor de fundo do botão por provider.
  static const backgroundColors = {
    'google': Colors.white,
    'facebook': Color(0xFF1877F2),
    'apple': Colors.black,
  };

  /// Cor da borda do botão por provider.
  static const borderColors = {
    'google': LoginColors.stroke,
    'facebook': Colors.transparent,
    'apple': Colors.transparent,
  };

  /// Cor do texto do botão por provider.
  static const textColors = {
    'google': Color(0xFF364153),
    'facebook': Colors.white,
    'apple': Colors.white,
  };
}
