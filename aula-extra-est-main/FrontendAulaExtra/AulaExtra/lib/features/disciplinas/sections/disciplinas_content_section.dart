import 'package:aula_extra/features/disciplinas/sections/main_content_section.dart';
import 'package:aula_extra/features/disciplinas/sections/sidebar_section.dart';
import 'package:flutter/material.dart';

class DisciplinasContentSection extends StatelessWidget {
  const DisciplinasContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF9FAFB),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 69),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(width: 53),
              SidebarSection(),
              Expanded(child: MainContentSection()),
            ],
          ),
        ),
      ),
    );
  }
}
