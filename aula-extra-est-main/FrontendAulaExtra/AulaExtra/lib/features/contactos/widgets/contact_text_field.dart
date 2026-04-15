import 'package:flutter/material.dart';

class ContactTextField extends StatelessWidget {
  const ContactTextField({
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
            fontSize: 19.931,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 9.965),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: maxLines,
          style: const TextStyle(
            fontSize: 19.931,
            height: 1.5,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 19.931,
              color: Color(0x800A0A0A),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 19.931,
              vertical: 14.948,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.457),
              borderSide: const BorderSide(
                color: Color(0xFFE6E9EA),
                width: 1.246,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.457),
              borderSide: const BorderSide(
                color: Color(0xFFF15C64),
                width: 1.4,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.457),
              borderSide: const BorderSide(
                color: Color(0xFFB42318),
                width: 1.246,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.457),
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
