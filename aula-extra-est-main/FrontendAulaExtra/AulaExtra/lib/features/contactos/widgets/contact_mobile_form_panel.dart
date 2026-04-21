import 'package:aula_extra/core/data/contact_form/dtos/contact_form_category_dto.dart';
import 'package:aula_extra/features/contactos/constants/contactos_mobile_layout.dart';
import 'package:aula_extra/features/contactos/widgets/contact_mobile_dropdown_field.dart';
import 'package:aula_extra/features/contactos/widgets/contact_mobile_text_field.dart';
import 'package:flutter/material.dart';

class ContactMobileFormPanel extends StatelessWidget {
  const ContactMobileFormPanel({
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ContactosMobileLayout.cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enviar Mensagem',
                style: TextStyle(
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 18),
              ContactMobileTextField(
                label: 'Nome *',
                hintText: 'O teu nome',
                controller: nameController,
                validator: (value) => validateRequired(value, 'Nome'),
              ),
              const SizedBox(height: 16),
              ContactMobileTextField(
                label: 'Email *',
                hintText: 'O teu email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 16),
              ContactMobileDropdownField(
                label: 'Assunto *',
                value: selectedCategoryId,
                items: categories,
                isLoading: isLoadingCategories,
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: 16),
              ContactMobileTextField(
                label: 'Mensagem *',
                hintText: 'Escreve a tua mensagem aqui...',
                controller: messageController,
                maxLines: 6,
                validator: (value) => validateRequired(value, 'Mensagem'),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFB42318),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF15C64),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFF8A4A8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ContactosMobileLayout.cardRadius,
                      ),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
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
    );
  }
}
