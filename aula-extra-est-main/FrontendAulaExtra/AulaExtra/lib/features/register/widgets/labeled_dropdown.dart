import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:flutter/material.dart';

class LabeledDropdown extends StatelessWidget {
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  static const _items = <String>[
    'Seleciona o teu nível',
    'Ensino Primário',
    'Ensino Secundário',
    'Universidade',
    'Formação Profissional',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.703,
            fontWeight: FontWeight.w700,
            color: Color(0xFF364153),
            height: 16.719 / 11.703,
            letterSpacing: -0.1257,
          ),
        ),
        const SizedBox(height: 6.688),
        SizedBox(
          height: 43.469,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            onChanged: onChanged,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF99A1AF)),
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsetsDirectional.only(start: 13.375, end: 10),
                child: Icon(Icons.school_outlined, size: 16.719, color: Color(0xFF99A1AF)),
              ),
              prefixIconConstraints: const BoxConstraints.tightFor(width: 40.125, height: 43.469),
              contentPadding: const EdgeInsets.symmetric(horizontal: 13.375, vertical: 10.031),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11.703),
                borderSide: const BorderSide(color: RegisterColors.stroke, width: 1.672),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11.703),
                borderSide: const BorderSide(color: RegisterColors.stroke, width: 1.672),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11.703),
                borderSide: const BorderSide(color: RegisterColors.stroke, width: 1.672),
              ),
            ),
            hint: const Text(
              'Seleciona o teu nível',
              style: TextStyle(
                fontSize: 13.375,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(10, 10, 10, 0.5),
                letterSpacing: -0.2612,
              ),
            ),
            items: [
              for (final item in _items.skip(1))
                DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13.375,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0A0A0A),
                      letterSpacing: -0.2612,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
