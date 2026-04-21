import 'package:flutter/material.dart';

import 'alunos_header_section.dart';
import 'alunos_table_section.dart';

class AlunosOverviewSection extends StatelessWidget {
  const AlunosOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AlunosHeaderSection(),
        SizedBox(height: 37.273),
        AlunosTableSection(),
      ],
    );
  }
}
