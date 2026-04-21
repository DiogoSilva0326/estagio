import 'package:flutter/material.dart';

class AreaDisciplinasItem {
  const AreaDisciplinasItem({
    required this.nome,
    required this.explicadores,
    required this.disciplinas,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final String nome;
  final int explicadores;
  final List<String> disciplinas;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  AreaDisciplinasItem copyWith({
    String? nome,
    int? explicadores,
    List<String>? disciplinas,
    IconData? icon,
    Color? iconBackgroundColor,
    Color? iconColor,
  }) {
    return AreaDisciplinasItem(
      nome: nome ?? this.nome,
      explicadores: explicadores ?? this.explicadores,
      disciplinas: disciplinas ?? this.disciplinas,
      icon: icon ?? this.icon,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}
