import 'package:aula_extra/core/data/contact_form/dtos/contact_form_category_dto.dart';
import 'package:aula_extra/features/contactos/constants/contactos_mobile_layout.dart';
import 'package:flutter/material.dart';

class ContactMobileDropdownField extends StatelessWidget {
  const ContactMobileDropdownField({
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
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey<String?>(value),
          initialValue: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.idContactFormCategory,
                  child: Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15),
                  ),
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
            hintStyle: const TextStyle(fontSize: 15, color: Color(0x800A0A0A)),
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
