import 'package:aula_extra/core/data/contact_form/dtos/contact_form_category_dto.dart';
import 'package:aula_extra/features/contactos/widgets/contact_dropdown_field.dart';
import 'package:aula_extra/features/contactos/widgets/contact_text_field.dart';
import 'package:flutter/material.dart';

class ContactFormPanel extends StatelessWidget {
  const ContactFormPanel({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.messageController,
    required this.categories,
    required this.selectedCategoryId,
    required this.isLoadingCategories,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onCategoryChanged,
    required this.onSubmit,
    required this.validateRequired,
    required this.validateEmail,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController messageController;
  final List<ContactFormCategoryDto> categories;
  final String? selectedCategoryId;
  final bool isLoadingCategories;
  final bool isSubmitting;
  final String? errorMessage;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onSubmit;
  final String? Function(String?, String) validateRequired;
  final String? Function(String?) validateEmail;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 645.26,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.913),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24.913,
              offset: Offset(0, 4.983),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(49.827, 49.827, 49.827, 49.827),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enviar Mensagem',
                  style: TextStyle(
                    fontSize: 39.862,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 37.37),
                ContactTextField(
                  label: 'Nome *',
                  hintText: 'O teu nome',
                  controller: nameController,
                  validator: (value) => validateRequired(value, 'Nome'),
                ),
                const SizedBox(height: 24.913),
                ContactTextField(
                  label: 'Email *',
                  hintText: 'O teu email',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 24.913),
                ContactDropdownField(
                  label: 'Assunto *',
                  value: selectedCategoryId,
                  items: categories,
                  isLoading: isLoadingCategories,
                  onChanged: onCategoryChanged,
                ),
                const SizedBox(height: 24.913),
                ContactTextField(
                  label: 'Mensagem *',
                  hintText: 'Escreve a tua mensagem aqui...',
                  controller: messageController,
                  maxLines: 7,
                  validator: (value) => validateRequired(value, 'Mensagem'),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 18),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFB42318),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 37.37),
                SizedBox(
                  width: double.infinity,
                  height: 69.758,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF15C64),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFF8A4A8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.913),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 19.931,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Enviar Mensagem'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
