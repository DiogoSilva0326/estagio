import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:aula_extra/features/register/constants/register_mobile_layout.dart';
import 'package:flutter/material.dart';

class RegisterMobileDropdown extends StatelessWidget {
  const RegisterMobileDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  static const items = <String>[
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF364153),
            letterSpacing: -0.1504,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: RegisterMobileLayout.inputHeight,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            onChanged: onChanged,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20,
              color: Color(0xFF99A1AF),
            ),
            decoration: InputDecoration(
              prefixIcon: const Padding(
                padding: EdgeInsetsDirectional.only(start: 12, end: 8),
                child: Icon(
                  Icons.school_outlined,
                  size: 20,
                  color: Color(0xFF99A1AF),
                ),
              ),
              prefixIconConstraints: const BoxConstraints.tightFor(
                width: 40,
                height: RegisterMobileLayout.inputHeight,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: RegisterColors.stroke,
                  width: 0.691,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: RegisterColors.stroke,
                  width: 0.691,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: RegisterColors.stroke,
                  width: 0.691,
                ),
              ),
            ),
            hint: const Text(
              'Seleciona o teu nível',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(10, 10, 10, 0.5),
                letterSpacing: -0.3125,
              ),
            ),
            items: [
              for (final item in items)
                DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
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
