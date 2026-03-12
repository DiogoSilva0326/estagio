class AppTypography {
  const AppTypography._();

  /// Note: "Helvetica Neue" is a system font on Apple platforms.
  /// On Android/Web it may not exist; fallback fonts are provided in the theme.
  static const String fontFamily = 'Helvetica Neue';

  static const List<String> fontFamilyFallback = <String>[
    'Helvetica',
    'Arial',
    'sans-serif',
  ];
}
