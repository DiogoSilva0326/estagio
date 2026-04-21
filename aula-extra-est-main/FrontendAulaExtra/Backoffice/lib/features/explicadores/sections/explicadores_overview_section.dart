import 'package:flutter/material.dart';

import 'explicadores_header_section.dart';
import 'explicadores_table_section.dart';

class ExplicadoresOverviewSection extends StatelessWidget {
  const ExplicadoresOverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExplicadoresHeaderSection(),
        SizedBox(height: 37.273),
        ExplicadoresTableSection(),
      ],
    );
  }
}
