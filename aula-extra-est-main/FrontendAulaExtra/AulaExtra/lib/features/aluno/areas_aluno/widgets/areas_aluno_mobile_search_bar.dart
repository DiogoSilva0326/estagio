import 'package:flutter/material.dart';

class AreasAlunoMobileSearchBar extends StatelessWidget {
  const AreasAlunoMobileSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Procurar disciplinas...',
        hintStyle: const TextStyle(fontSize: 15, color: Color(0x804A5565)),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4A5565)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFFF6B00)),
        ),
      ),
    );
  }
}
