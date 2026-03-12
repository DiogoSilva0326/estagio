import 'package:aula_extra/features/tutor_profile_view/widgets/review_card.dart';
import 'package:flutter/material.dart';

class ReviewsList extends StatelessWidget {
  const ReviewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ReviewCard(
          name: 'Maria Silva',
          when: '2 semanas atrás',
          rating: 5,
          text: 'Excelente explicador! Muito paciente e com ótimas técnicas de ensino.',
        ),
        SizedBox(height: 20.426),
        ReviewCard(
          name: 'Ana Costa',
          when: '1 mês atrás',
          rating: 5,
          text: 'Recomendo! Melhorei muito o meu inglês com as aulas dele.',
        ),
        SizedBox(height: 20.426),
        ReviewCard(
          name: 'Beatriz Ferreira',
          when: '2 meses atrás',
          rating: 4,
          text: 'Muito bom! Só às vezes a conexão da internet falha.',
        ),
      ],
    );
  }
}
