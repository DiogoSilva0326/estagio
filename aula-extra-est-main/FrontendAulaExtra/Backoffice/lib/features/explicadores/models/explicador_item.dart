import 'package:flutter/material.dart';

class ExplicadorItem {
  const ExplicadorItem({
    this.idProfessor = '',
    this.category = 'explicadores',
    this.photoUrl,
    required this.initials,
    required this.name,
    required this.email,
    this.areaLabel = 'Sem área',
    required this.mainSubject,
    required this.priceLabel,
    required this.ratingLabel,
    required this.statusLabel,
    this.isActive = false,
    this.isVerified = false,
    this.isRejected = false,
    required this.statusColor,
    required this.statusBackgroundColor,
    this.phone,
    this.location,
    this.candidateMessage,
    this.degreeTitle,
    this.degreeInstitution,
    this.documentLabel,
    this.documentActionLabel,
    this.videoDuration,
    this.reviewStatusLabel,
    this.reviewStatusColor,
    this.reviewStatusBackgroundColor,
    this.verifications = const [],
  });

  final String idProfessor;
  final String category;
  final String? photoUrl;
  final String initials;
  final String name;
  final String email;
  final String areaLabel;
  final String mainSubject;
  final String priceLabel;
  final String ratingLabel;
  final String statusLabel;
  final bool isActive;
  final bool isVerified;
  final bool isRejected;
  final Color statusColor;
  final Color statusBackgroundColor;
  final String? phone;
  final String? location;
  final String? candidateMessage;
  final String? degreeTitle;
  final String? degreeInstitution;
  final String? documentLabel;
  final String? documentActionLabel;
  final String? videoDuration;
  final String? reviewStatusLabel;
  final Color? reviewStatusColor;
  final Color? reviewStatusBackgroundColor;
  final List<ExplicadorVerificationItem> verifications;

  bool get isApproved => isActive && isVerified && !isRejected;
  String get verifiedLabel => isVerified ? 'VERIFICADO' : 'NÃO VERIFICADO';
  String get moderationLabel => isRejected ? 'REJEITADO' : isApproved ? 'APROVADO' : 'PENDENTE';
}

class ExplicadorVerificationItem {
  const ExplicadorVerificationItem({
    required this.label,
    required this.icon,
    this.isApproved = true,
  });

  final String label;
  final IconData icon;
  final bool isApproved;
}
