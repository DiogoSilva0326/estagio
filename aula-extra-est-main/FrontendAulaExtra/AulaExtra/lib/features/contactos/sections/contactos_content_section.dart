import 'package:aula_extra/core/data/contact_form/contact_form_api.dart';
import 'package:aula_extra/core/data/contact_form/contact_form_service.dart';
import 'package:aula_extra/core/data/contact_form/dtos/contact_form_category_dto.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/contactos/widgets/contact_form_panel.dart';
import 'package:aula_extra/features/contactos/widgets/contact_info_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContactosContentSection extends StatefulWidget {
  const ContactosContentSection({super.key});

  @override
  State<ContactosContentSection> createState() =>
      _ContactosContentSectionState();
}

class _ContactosContentSectionState extends State<ContactosContentSection> {
  final ContactFormService _service = ContactFormService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _messageController;

  List<ContactFormCategoryDto> _categories = const [];
  String? _selectedCategoryId;
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool _didPrefillUser = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _messageController = TextEditingController();
    _loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrefillUser) return;
    final account = context.read<UserProvider>().account;
    _nameController.text = account?.fullName?.trim().isNotEmpty == true
        ? account!.fullName!.trim()
        : (account?.username?.trim() ?? '');
    _emailController.text = account?.email?.trim() ?? '';
    _didPrefillUser = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _errorMessage = null;
    });

    try {
      final categories = await _service.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _selectedCategoryId = categories.isNotEmpty
            ? categories.first.idContactFormCategory
            : null;
        _isLoadingCategories = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingCategories = false;
        _errorMessage = error is ContactFormException
            ? error.message
            : 'Não foi possível carregar os assuntos.';
      });
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting || _isLoadingCategories) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final categoryId = _selectedCategoryId;
    if (categoryId == null || categoryId.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Seleciona um assunto antes de enviar.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _service.createSubmission(
        idContactFormCategory: categoryId,
        name: _nameController.text,
        email: _emailController.text,
        message: _messageController.text,
      );

      if (!mounted) return;
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensagem enviada com sucesso.'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is ContactFormException
            ? error.message
            : 'Não foi possível enviar a tua mensagem.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _validateRequired(String? value, String fieldLabel) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'O campo $fieldLabel é obrigatório.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final required = _validateRequired(value, 'Email');
    if (required != null) return required;
    final normalized = value!.trim();
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(normalized)) {
      return 'Introduz um email válido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(37.37, 84.39, 37.37, 53.0),
      child: SizedBox(
        width: 1365.26,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: const ContactInfoPanel()),
                ContactFormPanel(
                  formKey: _formKey,
                  nameController: _nameController,
                  emailController: _emailController,
                  messageController: _messageController,
                  categories: _categories,
                  selectedCategoryId: _selectedCategoryId,
                  isLoadingCategories: _isLoadingCategories,
                  isSubmitting: _isSubmitting,
                  errorMessage: _errorMessage,
                  onCategoryChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                  onSubmit: _submit,
                  validateRequired: _validateRequired,
                  validateEmail: _validateEmail,
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
