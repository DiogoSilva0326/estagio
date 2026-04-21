import 'package:flutter/material.dart';

class PlanoItem {
  const PlanoItem({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.priceLabel,
    required this.badgeLabel,
    required this.badgeBackgroundColor,
    required this.badgeTextColor,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final String name;
  final String subtitle;
  final String description;
  final String priceLabel;
  final String badgeLabel;
  final Color badgeBackgroundColor;
  final Color badgeTextColor;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;

  PlanoItem copyWith({
    String? name,
    String? subtitle,
    String? description,
    String? priceLabel,
    String? badgeLabel,
    Color? badgeBackgroundColor,
    Color? badgeTextColor,
    IconData? icon,
    Color? iconBackgroundColor,
    Color? iconColor,
  }) {
    return PlanoItem(
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      priceLabel: priceLabel ?? this.priceLabel,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      badgeBackgroundColor: badgeBackgroundColor ?? this.badgeBackgroundColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      icon: icon ?? this.icon,
      iconBackgroundColor: iconBackgroundColor ?? this.iconBackgroundColor,
      iconColor: iconColor ?? this.iconColor,
    );
  }
}
