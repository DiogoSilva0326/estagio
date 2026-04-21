import 'package:flutter/material.dart';

class SessaoAulaItem {
  const SessaoAulaItem({
    required this.codigo,
    required this.aluno,
    required this.explicador,
    required this.disciplina,
    required this.dataHora,
    required this.duracao,
    required this.linkSalaLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBackgroundColor,
    this.showStatusDot = false,
    this.canEnterRoom = false,
  });

  final String codigo;
  final String aluno;
  final String explicador;
  final String disciplina;
  final String dataHora;
  final String duracao;
  final String linkSalaLabel;
  final String statusLabel;
  final Color statusColor;
  final Color statusBackgroundColor;
  final bool showStatusDot;
  final bool canEnterRoom;
}
