import 'package:flutter/material.dart';

class AreaDisciplinaEntry {
  const AreaDisciplinaEntry({
    required this.idDisciplina,
    required this.idArea,
    required this.nome,
  });

  final String idDisciplina;
  final String idArea;
  final String nome;
}

class AreaDisciplinasItem {
  const AreaDisciplinasItem({
    required this.idArea,
    required this.nome,
    required this.targetRole, 
    required this.explicadores,
    required this.disciplinas,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final String idArea;
  final String nome;
  final String targetRole; 
  final int explicadores;
  final List<AreaDisciplinaEntry> disciplinas;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  AreaDisciplinasItem copyWith({
    String? idArea,
    String? nome,
    String? targetRole, 
    int? explicadores,
    List<AreaDisciplinaEntry>? disciplinas,
    IconData? icon,
    Color? iconBackgroundColor,
    Color? iconColor,
  }) {
    return AreaDisciplinasItem(
      idArea: idArea ?? this.idArea,
      nome: nome ?? this.nome,
      targetRole: targetRole ?? this.targetRole, 
      explicadores: explicadores ?? this.explicadores,
      disciplinas: disciplinas ?? this.disciplinas,
      icon: icon ?? this.icon,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}