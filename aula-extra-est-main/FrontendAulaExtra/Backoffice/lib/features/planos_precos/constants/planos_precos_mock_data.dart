import 'package:flutter/material.dart';

import '../models/plano_item.dart';

const String basePlatformCommission = '20';

const List<PlanoItem> planosPrecosMockData = [
  PlanoItem(
    id: 'mock-pack-basico',
    courseId: 'mock-course-basico',
    name: 'Pack Básico',
    subtitle: '',
    description:
      'Plano ideal para reforço semanal.\nAcesso a sessões semanais.\nSuporte essencial.',
    priceLabel: '30€',
    numberOfLessons: 2,
    isActive: true,
    badgeLabel: 'Simples',
    badgeBackgroundColor: Color(0xFFEAFBF3),
    badgeTextColor: Color(0xFF027A48),
    icon: Icons.school_outlined,
    iconBackgroundColor: Color(0xFFEAF2FB),
    iconColor: Color(0xFF41A7D7),
  ),
  PlanoItem(
    id: 'mock-pack-intermedio',
    courseId: 'mock-course-intermedio',
    name: 'Pack Intermédio',
    subtitle: '',
    description:
      'Plano ideal para reforço mensal.\nMais flexibilidade de marcação.\nApoio prioritário.',
    priceLabel: '100€',
    numberOfLessons: 8,
    isActive: true,
    badgeLabel: 'Mais Popular',
    badgeBackgroundColor: Color(0xFFFFF2E8),
    badgeTextColor: Color(0xFFFB7B02),
    icon: Icons.workspace_premium_outlined,
    iconBackgroundColor: Color(0xFFFFF2E8),
    iconColor: Color(0xFFFB7B02),
  ),
  PlanoItem(
    id: 'mock-pack-personalizado',
    courseId: 'mock-course-personalizado',
    name: 'Pack Personalizado',
    subtitle: '',
    description: 'Plano ajustado às necessidades do aluno.',
    priceLabel: '200€',
    numberOfLessons: 12,
    isActive: true,
    badgeLabel: 'Personalizado',
    badgeBackgroundColor: Color(0xFFEEF2FF),
    badgeTextColor: Color(0xFF4F46E5),
    icon: Icons.tune_rounded,
    iconBackgroundColor: Color(0xFFFCEFE4),
    iconColor: Color(0xFFFC9039),
  ),
];
