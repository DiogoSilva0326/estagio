import 'package:aula_extra/core/data/complaints/dtos/related_user_complaint_request_dto.dart';
import 'package:aula_extra/features/contactos/widgets/contact_text_field.dart';
import 'package:flutter/material.dart';

class RelatedUserComplaintDialog extends StatefulWidget {
  const RelatedUserComplaintDialog({
    super.key,
    required this.targetUserId,
    required this.targetName,
    required this.targetRoleLabel,
    required this.relationshipType,
    required this.onSubmit,
  });

  final String targetUserId;
  final String targetName;
  final String targetRoleLabel;
  final String relationshipType;
  final Future<void> Function(RelatedUserComplaintRequestDto request) onSubmit;

  @override
  State<RelatedUserComplaintDialog> createState() =>
      _RelatedUserComplaintDialogState();
}

class _RelatedUserComplaintDialogState
    extends State<RelatedUserComplaintDialog> {
  static const List<String> _types = [
    'Comportamento',
    'Comunicação',
    'Pontualidade',
    'Qualidade da aula',
    'Outro',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subjectController;
  late final TextEditingController _messageController;
  String _selectedType = _types.first;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(
      text: 'Reclamação sobre ${widget.targetName}',
    );
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String label) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'O campo $label é obrigatório.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onSubmit(
        RelatedUserComplaintRequestDto(
          targetUserId: widget.targetUserId,
          relationshipType: widget.relationshipType,
          complaintType: _selectedType,
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
                            'Submeter reclamação',
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
                    Text(
                      'Estás a reportar ${widget.targetRoleLabel} ${widget.targetName}. Explica o problema para a equipa analisar.',
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Color(0xFF4A5565),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _ComplaintTypeField(
                      value: _selectedType,
                      options: _types,
                      onChanged: (value) {
                        if (value == null || value.trim().isEmpty) return;
                        setState(() {
                          _selectedType = value;
                        });
                      },
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
                      hintText: 'Descreve o que aconteceu...',
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

class _ComplaintTypeField extends StatelessWidget {
  const _ComplaintTypeField({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de reclamação *',
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
          items: options
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          decoration: InputDecoration(
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
          ),
        ),
      ],
    );
  }
}