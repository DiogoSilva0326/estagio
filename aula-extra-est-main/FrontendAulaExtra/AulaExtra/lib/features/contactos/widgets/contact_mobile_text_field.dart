import 'package:aula_extra/features/contactos/constants/contactos_mobile_layout.dart';
import 'package:flutter/material.dart';

class ContactMobileTextField extends StatelessWidget {
  const ContactMobileTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 15, color: Color(0x800A0A0A)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ContactosMobileLayout.inputRadius,
              ),
              borderSide: const BorderSide(color: Color(0xFFE6E9EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ContactosMobileLayout.inputRadius,
              ),
              borderSide: const BorderSide(
                color: Color(0xFFF15C64),
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ContactosMobileLayout.inputRadius,
              ),
              borderSide: const BorderSide(color: Color(0xFFB42318)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                ContactosMobileLayout.inputRadius,
              ),
              borderSide: const BorderSide(
                color: Color(0xFFB42318),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
