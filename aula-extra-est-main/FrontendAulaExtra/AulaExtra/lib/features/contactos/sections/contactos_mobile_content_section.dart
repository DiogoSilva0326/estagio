import 'package:aula_extra/core/data/contact_form/dtos/contact_form_category_dto.dart';
import 'package:aula_extra/features/contactos/constants/contactos_mobile_layout.dart';
import 'package:aula_extra/features/contactos/widgets/contact_mobile_form_panel.dart';
import 'package:aula_extra/features/contactos/widgets/contact_mobile_info_panel.dart';
import 'package:flutter/material.dart';

class ContactosMobileContentSection extends StatelessWidget {
  const ContactosMobileContentSection({
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ContactosMobileLayout.horizontalPadding,
        ContactosMobileLayout.verticalPadding,
        ContactosMobileLayout.horizontalPadding,
        32,
      ),
      child: Column(
        children: [
          const ContactMobileInfoPanel(),
          const SizedBox(height: ContactosMobileLayout.sectionSpacing),
          ContactMobileFormPanel(
            formKey: formKey,
            nameController: nameController,
            emailController: emailController,
            messageController: messageController,
            categories: categories,
            selectedCategoryId: selectedCategoryId,
            isLoadingCategories: isLoadingCategories,
            isSubmitting: isSubmitting,
            errorMessage: errorMessage,
            onCategoryChanged: onCategoryChanged,
            onSubmit: onSubmit,
            validateRequired: validateRequired,
            validateEmail: validateEmail,
          ),
        ],
      ),
    );
  }
}
