import 'package:aula_extra/features/disciplinas/constants/disciplinas_mobile_layout.dart';
import 'package:flutter/material.dart';

class DisciplinasMobileSearchBar extends StatelessWidget {
  const DisciplinasMobileSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DisciplinasMobileLayout.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DisciplinasMobileLayout.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: Color(0xFFBCBDBB)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Procurar disciplinas...',
                hintStyle: TextStyle(fontSize: 16, color: Color(0xFFBCBDBB)),
              ),
              style: const TextStyle(
                fontSize: 16,
                color: DisciplinasMobileLayout.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
