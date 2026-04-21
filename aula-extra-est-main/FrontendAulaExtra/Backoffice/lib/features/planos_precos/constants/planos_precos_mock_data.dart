import 'package:flutter/material.dart';

import '../models/plano_item.dart';

const String basePlatformCommission = '20';

const List<PlanoItem> planosPrecosMockData = [
  PlanoItem(
    name: 'Pack Básico',
    subtitle: 'O plano ideal para reforço semanal.',
    description:
        '2 créditos por semana\nAcesso a sessões semanais\nSuporte essencial',
    priceLabel: '30€',
    badgeLabel: 'Simples',
    badgeBackgroundColor: Color(0xFFEAFBF3),
    badgeTextColor: Color(0xFF027A48),
    icon: Icons.school_outlined,
    iconBackgroundColor: Color(0xFFEAF2FB),
    iconColor: Color(0xFF41A7D7),
  ),
  PlanoItem(
    name: 'Pack Intermédio',
    subtitle: 'O plano ideal para reforço mensal.',
    description:
        '8 créditos por mês\nMais flexibilidade de marcação\nApoio prioritário',
    priceLabel: '100€',
    badgeLabel: 'Mais Popular',
    badgeBackgroundColor: Color(0xFFFFF2E8),
    badgeTextColor: Color(0xFFFB7B02),
    icon: Icons.workspace_premium_outlined,
    iconBackgroundColor: Color(0xFFFFF2E8),
    iconColor: Color(0xFFFB7B02),
  ),
  PlanoItem(
    name: 'Pack Personalizado',
    subtitle: 'Selecione o número de\nCréditos',
    description: '',
    priceLabel: '200€',
    badgeLabel: 'Personalizado',
    badgeBackgroundColor: Color(0xFFEEF2FF),
    badgeTextColor: Color(0xFF4F46E5),
    icon: Icons.tune_rounded,
    iconBackgroundColor: Color(0xFFFCEFE4),
    iconColor: Color(0xFFFC9039),
  ),
];
