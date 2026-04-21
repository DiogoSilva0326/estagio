import 'package:flutter/material.dart';

import 'sessoes_aulas_header_section.dart';
import 'sessoes_aulas_table_section.dart';

class SessoesAulasOverviewSection extends StatelessWidget {
  const SessoesAulasOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SessoesAulasHeaderSection(),
        SizedBox(height: 37.273),
        SessoesAulasTableSection(),
      ],
    );
  }
}
