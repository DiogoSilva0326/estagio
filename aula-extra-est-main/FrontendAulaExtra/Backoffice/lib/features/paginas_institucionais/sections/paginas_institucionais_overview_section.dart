import 'package:flutter/material.dart';

import '../models/institutional_page_item.dart';
import 'paginas_institucionais_header_section.dart';
import 'paginas_institucionais_table_section.dart';

class PaginasInstitucionaisOverviewSection extends StatelessWidget {
  const PaginasInstitucionaisOverviewSection({
    required this.items,
    required this.onCreate,
    required this.onEdit,
    required this.onPreview,
    super.key,
  });

  final List<InstitutionalPageItem> items;
  final VoidCallback onCreate;
  final ValueChanged<InstitutionalPageItem> onEdit;
  final ValueChanged<InstitutionalPageItem> onPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaginasInstitucionaisHeaderSection(onCreate: onCreate),
        const SizedBox(height: 37.273),
        PaginasInstitucionaisTableSection(
          items: items,
          onEdit: onEdit,
          onPreview: onPreview,
        ),
      ],
    );
  }
}
