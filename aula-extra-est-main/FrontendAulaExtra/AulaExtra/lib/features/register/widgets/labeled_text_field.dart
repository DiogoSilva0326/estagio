import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:flutter/material.dart';

class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefix,
    this.suffix,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final Widget prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

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
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 13.375,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(10, 10, 10, 0.5),
                letterSpacing: -0.2612,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(start: 13.375, end: 10),
                child: prefix,
              ),
              prefixIconConstraints: const BoxConstraints.tightFor(width: 40.125, height: 43.469),
              suffixIcon: suffix,
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
          ),
        ),
      ],
    );
  }
}
