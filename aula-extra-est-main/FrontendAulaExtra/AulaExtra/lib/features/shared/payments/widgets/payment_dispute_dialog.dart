import 'package:aula_extra/core/data/payments/dtos/payment_dispute_request_dto.dart';
import 'package:aula_extra/features/contactos/widgets/contact_text_field.dart';
import 'package:flutter/material.dart';

class PaymentDisputeOption {
  const PaymentDisputeOption({
    required this.id,
    required this.paymentSource,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String paymentSource;
  final String title;
  final String subtitle;
}

class PaymentDisputeDialog extends StatefulWidget {
  const PaymentDisputeDialog({
    super.key,
    required this.options,
    required this.initialName,
    required this.initialEmail,
    required this.onSubmit,
  });

  final List<PaymentDisputeOption> options;
  final String initialName;
  final String initialEmail;
  final Future<void> Function(PaymentDisputeRequestDto request) onSubmit;

  @override
  State<PaymentDisputeDialog> createState() => _PaymentDisputeDialogState();
}

class _PaymentDisputeDialogState extends State<PaymentDisputeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _subjectController;
  late final TextEditingController _messageController;
  String? _selectedPaymentId;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _subjectController = TextEditingController(
      text: widget.options.isNotEmpty
          ? 'Reclamação sobre ${widget.options.first.title}'
          : 'Reclamação sobre pagamento',
    );
    _messageController = TextEditingController();
    _selectedPaymentId = widget.options.isNotEmpty ? widget.options.first.id : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
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

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final selectedOption = widget.options.where((item) => item.id == _selectedPaymentId).firstOrNull;
    if (selectedOption == null) {
      setState(() {
        _errorMessage = 'Seleciona um pagamento antes de enviar.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onSubmit(
        PaymentDisputeRequestDto(
          paymentRecordId: selectedOption.id,
          paymentSource: selectedOption.paymentSource,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          subject: _subjectController.text.trim(),
          message: _messageController.text.trim(),
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 645.26),
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
            padding: const EdgeInsets.fromLTRB(49.827, 40, 49.827, 49.827),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Submeter reclamação sobre pagamentos',
                            style: TextStyle(
                              fontSize: 32,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Escolhe o pagamento relacionado e descreve o problema para a equipa analisar.',
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _PaymentDropdownField(
                      value: _selectedPaymentId,
                      items: widget.options,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24.913),
                    ContactTextField(
                      label: 'Nome *',
                      hintText: 'O teu nome',
                      controller: _nameController,
                      validator: (value) => _validateRequired(value, 'Nome'),
                    ),
                    const SizedBox(height: 24.913),
                    ContactTextField(
                      label: 'Email *',
                      hintText: 'O teu email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 24.913),
                    ContactTextField(
                      label: 'Assunto *',
                      hintText: 'Resumo curto da reclamação',
                      controller: _subjectController,
                      validator: (value) => _validateRequired(value, 'Assunto'),
                    ),
                    const SizedBox(height: 24.913),
                    ContactTextField(
                      label: 'Mensagem *',
                      hintText: 'Explica o que aconteceu com este pagamento...',
                      controller: _messageController,
                      maxLines: 7,
                      validator: (value) => _validateRequired(value, 'Mensagem'),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 18),
                      Text(
                        _errorMessage!,
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
                        onPressed: _isSubmitting ? null : _submit,
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
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Submeter reclamação'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentDropdownField extends StatelessWidget {
  const _PaymentDropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final List<PaymentDisputeOption> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pagamento *',
          style: TextStyle(
            fontSize: 19.931,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 9.965),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          itemHeight: null,
          menuMaxHeight: 360,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.id,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
          selectedItemBuilder: (context) {
            return items
                .map(
                  (item) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                )
                .toList(growable: false);
          },
          onChanged: onChanged,
          validator: (selected) {
            if ((selected ?? '').trim().isEmpty) {
              return 'Seleciona um pagamento.';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Seleciona o pagamento',
            hintStyle: const TextStyle(
              fontSize: 19.931,
              color: Color(0x800A0A0A),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 19.931,
              vertical: 18,
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