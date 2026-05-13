import 'package:flutter/material.dart';

class SessaoAulaItem {
  const SessaoAulaItem({
    required this.id,
    required this.reservationId,
    required this.lessonId,
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
    this.videoCallId,
    this.showStatusDot = false,
    this.canEnterRoom = false,
    this.startsAt,
    this.endsAt,
    this.channelName,
    this.recordingUrl,
    this.reservationStatus = '',
    this.videoCallStatus = '',
  });

  final String id;
  final String reservationId;
  final String lessonId;
  final String? videoCallId;
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
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? channelName;
  final String? recordingUrl;
  final String reservationStatus;
  final String videoCallStatus;
}
