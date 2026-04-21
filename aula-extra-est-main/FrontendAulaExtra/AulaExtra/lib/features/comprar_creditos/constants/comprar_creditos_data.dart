import 'package:flutter/material.dart';

class CreditPackageData {
  const CreditPackageData({
    required this.title,
    required this.credits,
    required this.priceLabel,
    required this.caption,
    required this.features,
    this.badge,
    this.badgeGradient,
    this.badgeColor,
    this.highlighted = false,
  });

  final String title;
  final int credits;
  final String priceLabel;
  final String caption;
  final List<String> features;
  final String? badge;
  final List<Color>? badgeGradient;
  final Color? badgeColor;
  final bool highlighted;
}

class CreditStepData {
  const CreditStepData({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

class ComprarCreditosData {
  const ComprarCreditosData._();

  static const benefits = [
    'Sem subscrição obrigatória',
    'Créditos utilizáveis em várias disciplinas',
    'Pagamento simples e seguro',
    'Saldo visível no teu perfil',
  ];

  static const packages = [
    CreditPackageData(
      title: 'Pack Básico',
      credits: 30,
      priceLabel: '30€',
      caption: 'O plano ideal para reforço semanal.',
      features: [
        '2 Aulas',
        'Válido por 1 ano',
        'Sem compromisso',
        'Preço unitário (opcional, em pequeno): (15€ / aula)',
      ],
      badge: 'Simples',
      badgeColor: Color(0xFF000000),
    ),
    CreditPackageData(
      title: 'Pack Intermédio',
      credits: 100,
      priceLabel: '100€',
      caption: 'O plano ideal para reforço mensal.',
      features: [
        '10 Aulas',
        'Válido por 1 ano',
        'Sem compromisso',
        'Preço unitário (opcional, em pequeno): (15€ / aula)',
      ],
      badge: 'Mais Popular',
      badgeColor: Color(0xFFF15C64),
      highlighted: true,
    ),
  ];

  static const steps = [
    CreditStepData(
      title: 'Escolhe um pacote',
      description:
          'Seleciona a quantidade de créditos que faz mais sentido para o teu ritmo.',
      icon: Icons.wallet_rounded,
    ),
    CreditStepData(
      title: 'Conclui o pagamento',
      description:
          'Finaliza o checkout de forma rápida e segura em poucos passos.',
      icon: Icons.lock_rounded,
    ),
    CreditStepData(
      title: 'Marca as tuas aulas',
      description:
          'Usa o saldo para reservar explicações sempre que precisares.',
      icon: Icons.calendar_month_rounded,
    ),
  ];
}
