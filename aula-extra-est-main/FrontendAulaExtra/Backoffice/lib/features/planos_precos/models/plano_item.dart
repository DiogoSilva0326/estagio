import 'package:flutter/material.dart';

class PlanoItem {
  const PlanoItem({
    required this.id,
    required this.courseId,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.priceLabel,
    required this.numberOfLessons,
    required this.isActive,
    required this.badgeLabel,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final String id;
  final String courseId;
  final String name;
  final String subtitle;
  final String description;
  final String priceLabel;
  final int numberOfLessons;
  final bool isActive;
  final String badgeLabel;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  PlanoItem copyWith({
    String? id,
    String? courseId,
    String? name,
    String? subtitle,
    String? description,
    String? priceLabel,
    int? numberOfLessons,
    bool? isActive,
    String? badgeLabel,
    Color? badgeBackgroundColor,
    Color? badgeTextColor,
    IconData? icon,
    Color? iconBackgroundColor,
    Color? iconColor,
  }) {
    return PlanoItem(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      priceLabel: priceLabel ?? this.priceLabel,
      numberOfLessons: numberOfLessons ?? this.numberOfLessons,
      isActive: isActive ?? this.isActive,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      badgeBackgroundColor: badgeBackgroundColor ?? this.badgeBackgroundColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      icon: icon ?? this.icon,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}
