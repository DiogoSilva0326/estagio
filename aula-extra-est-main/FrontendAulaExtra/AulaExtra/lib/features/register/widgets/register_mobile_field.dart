import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:aula_extra/features/register/constants/register_mobile_layout.dart';
import 'package:flutter/material.dart';

class RegisterMobileField extends StatelessWidget {
  const RegisterMobileField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefix,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.suffix,
  });

  final String label;
  final String hintText;
  final Widget prefix;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

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
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(10, 10, 10, 0.5),
                letterSpacing: -0.3125,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
                child: prefix,
              ),
              prefixIconConstraints: const BoxConstraints.tightFor(
                width: 40,
                height: RegisterMobileLayout.inputHeight,
              ),
              suffixIcon: suffix,
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
          ),
        ),
      ],
    );
  }
}
