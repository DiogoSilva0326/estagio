import 'package:flutter/material.dart';

class DisponibilidadeProfessorConstants {
  const DisponibilidadeProfessorConstants._();

  static const Color blockInactiveBg = Color(0xFFF9FAFB);
  static const Color blockActiveBg = Color(0xFFFFF7ED);
  static const Color blockInactiveBorder = Color(0xFFEAECF0);
  static const Color blockActiveBorder = Color(0xFFFF6B00); 
  
  static const Color textMain = Color(0xFF101828);
  static const Color textMuted = Color(0xFF667085);

  static const double cardRadius = 22.404;
  static const double blockRadius = 16.0;
  static const double cardBorderWidth = 1.4;
  static const double blockHeight = 65.0;
  
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 1.4), blurRadius: 4.201),
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.10), offset: Offset(0, 1.4), blurRadius: 2.801),
  ];

  static const TextStyle gridHeaderStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textMain,
  );
}