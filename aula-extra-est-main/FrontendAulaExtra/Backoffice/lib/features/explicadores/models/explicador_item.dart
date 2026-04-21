import 'package:flutter/material.dart';

class ExplicadorItem {
  const ExplicadorItem({
    required this.initials,
    required this.name,
    required this.email,
    required this.mainSubject,
    required this.priceLabel,
    required this.ratingLabel,
    required this.statusLabel,
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

  final String initials;
  final String name;
  final String email;
  final String mainSubject;
  final String priceLabel;
  final String ratingLabel;
  final String statusLabel;
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
