import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class FaqCategoryDialogResult {
  const FaqCategoryDialogResult({
    required this.label,
    this.description,
  });

  final String label;
  final String? description;
}

class FaqCategoryDialog extends StatefulWidget {
  const FaqCategoryDialog({super.key});

  @override
  State<FaqCategoryDialog> createState() => _FaqCategoryDialogState();
}

class _FaqCategoryDialogState extends State<FaqCategoryDialog> {
  late final TextEditingController _labelController;
  late final TextEditingController _descriptionController;

  bool get _canSubmit => _labelController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController()..addListener(_onChanged);
    _descriptionController = TextEditingController()..addListener(_onChanged);
  }

  @override
  void dispose() {
    _labelController
      ..removeListener(_onChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _close() => Navigator.of(context).pop();

  void _submit() {
    if (!_canSubmit) {
      return;
    }

    Navigator.of(context).pop(
      FaqCategoryDialogResult(
        label: _labelController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 24, 24, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFC9039),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.category_outlined,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Criar categoria FAQ',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Adicione uma nova categoria para organizar as perguntas frequentes no backoffice.',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _close,
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                  child: Column(
                    children: [
                      _DialogField(
                        label: 'Nome da categoria',
                        child: _DialogInput(
                          controller: _labelController,
                          hintText: 'Ex: Pagamentos, Plataforma, Conta',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DialogField(
                        label: 'Descrição',
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          minLines: 3,
                          decoration: _inputDecoration(
                            hintText: 'Descrição opcional da categoria.',
                          ),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 20, 32, 28),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      TextButton(
                        onPressed: _close,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF15C64), Color(0xFFFC9039)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _canSubmit ? _submit : null,
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Criar categoria'),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white70,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
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

class _DialogField extends StatelessWidget {
  const _DialogField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF364153),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _DialogInput extends StatelessWidget {
  const _DialogInput({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(hintText: hintText),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFFD1D5DC),
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFC9039)),
    ),
  );
}