import 'package:aula_extra/features/faq/widgets/faq_category_row.dart';
import 'package:aula_extra/features/faq/widgets/faq_contact_card.dart';
import 'package:aula_extra/features/faq/widgets/faq_groups.dart';
import 'package:flutter/material.dart';

class FaqMainBlock extends StatelessWidget {
  const FaqMainBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FaqCategoryRow(),
        SizedBox(height: 61.252),
        FaqGroups(),
        SizedBox(height: 40.834),
        FaqContactCard(),
      ],
    );
  }
}
