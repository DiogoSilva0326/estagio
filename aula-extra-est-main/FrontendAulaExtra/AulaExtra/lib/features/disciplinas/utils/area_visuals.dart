import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:flutter/material.dart';

class AreaVisuals {
  const AreaVisuals({
    required this.dotColor,
    required this.icon,
    this.imageAsset,
  });

  final String? imageAsset;
  final Color dotColor;
  final IconData icon;
}

AreaVisuals getAreaVisuals(String? areaName) {
  final normalized = _normalizeArea(areaName);

  if (normalized.contains('matemat')) {
    return const AreaVisuals(
      imageAsset: HomeAssets.areaMatematica,
      dotColor: Color(0xFF3B94EF),
      icon: Icons.calculate_rounded,
    );
  }
  if (normalized.contains('cien')) {
    return const AreaVisuals(
      imageAsset: HomeAssets.areaCiencias,
      dotColor: Color(0xFF45AB61),
      icon: Icons.science_rounded,
    );
  }
  if (normalized.contains('ling') || normalized.contains('idioma')) {
    return const AreaVisuals(
      imageAsset: HomeAssets.areaLinguas,
      dotColor: Color(0xFFFC9039),
      icon: Icons.language_rounded,
    );
  }
  if (normalized.contains('literat')) {
    return const AreaVisuals(
      imageAsset: HomeAssets.areaLiteratura,
      dotColor: Color(0xFF9B59B6),
      icon: Icons.menu_book_rounded,
    );
  }
  if (normalized.contains('program') || normalized.contains('informat')) {
    return const AreaVisuals(
      imageAsset: HomeAssets.areaProgramacao,
      dotColor: Color(0xFFE74C3C),
      icon: Icons.code_rounded,
    );
  }
  if (normalized.contains('geograf')) {
    return const AreaVisuals(
      imageAsset: HomeAssets.areaGeografia,
      dotColor: Color(0xFFF39C12),
      icon: Icons.public_rounded,
    );
  }
  if (normalized.contains('music')) {
    return const AreaVisuals(
      imageAsset: HomeAssets.areaMusica,
      dotColor: Color(0xFFFF8CEF),
      icon: Icons.music_note_rounded,
    );
  }
  if (normalized.contains('arte') || normalized.contains('design')) {
    return const AreaVisuals(
      imageAsset: HomeAssets.areaArtes,
      dotColor: Color(0xFFDAF508),
      icon: Icons.palette_rounded,
    );
  }

  return const AreaVisuals(
    dotColor: Color(0xFF6A7282),
    icon: Icons.school_rounded,
  );
}

String _normalizeArea(String? value) {
  const source = 'áàâãäåéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÅÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
  const target = 'aaaaaaeeeeiiiiooooouuuucnAAAAAAEEEEIIIIOOOOOUUUUCN';

  final input = (value ?? '').trim().toLowerCase();
  final buffer = StringBuffer();

  for (final rune in input.runes) {
    final character = String.fromCharCode(rune);
    final index = source.indexOf(character);
    buffer.write(index >= 0 ? target[index].toLowerCase() : character);
  }

  return buffer.toString();
}