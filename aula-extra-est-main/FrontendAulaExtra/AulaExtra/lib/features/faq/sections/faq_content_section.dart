import 'package:aula_extra/features/faq/widgets/faq_hero_block.dart';
import 'package:aula_extra/features/faq/widgets/faq_main_block.dart';
import 'package:flutter/material.dart';

class FaqContentSection extends StatelessWidget {
  const FaqContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FaqHeroBlock(),
        SizedBox(height: 61.252),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 66.36),
          child: FaqMainBlock(),
        ),
        SizedBox(height: 80),
      ],
    );
  }
}
