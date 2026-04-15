import 'package:aula_extra/core/data/contact_form/dtos/contact_form_category_dto.dart';
import 'package:flutter/material.dart';

class ContactDropdownField extends StatelessWidget {
  const ContactDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.isLoading,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<ContactFormCategoryDto> items;
  final bool isLoading;
  final ValueChanged<String?> onChanged;

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
        DropdownButtonFormField<String>(
          key: ValueKey<String?>(value),
          initialValue: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.idContactFormCategory,
                  child: Text(item.name),
                ),
              )
              .toList(growable: false),
          onChanged: isLoading ? null : onChanged,
          validator: (selected) {
            if ((selected ?? '').trim().isEmpty) {
              return 'Seleciona um assunto.';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: isLoading
                ? 'A carregar assuntos...'
                : 'Sobre o que queres falar?',
            hintStyle: const TextStyle(
              fontSize: 19.931,
              color: Color(0x800A0A0A),
            ),
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
