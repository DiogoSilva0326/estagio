import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/faq_item.dart';

class FaqDialogResult {
  const FaqDialogResult({
    required this.question,
    required this.answer,
    required this.categoryId,
    required this.categoryLabel,
  });

  final String question;
  final String answer;
  final String categoryId;
  final String categoryLabel;
}

class FaqDialog extends StatefulWidget {
  const FaqDialog({
    required this.categories,
    this.initialItem,
    super.key,
  });

  final List<FaqCategoryOption> categories;
  final FaqItem? initialItem;

  @override
  State<FaqDialog> createState() => _FaqDialogState();
}

class _FaqDialogState extends State<FaqDialog> {
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  late String? _selectedCategoryId;

  bool get _isEditing => widget.initialItem != null;

  bool get _canSubmit =>
      _questionController.text.trim().isNotEmpty &&
      _answerController.text.trim().isNotEmpty &&
      _selectedCategoryId != null &&
      _selectedCategoryId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialItem?.categoryId;
    if ((_selectedCategoryId == null || _selectedCategoryId!.isEmpty) &&
        widget.categories.isNotEmpty) {
      _selectedCategoryId = widget.categories.first.id;
    }
    _questionController = TextEditingController(
      text: widget.initialItem?.question,
    )..addListener(_onChanged);
    _answerController = TextEditingController(text: widget.initialItem?.answer)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _questionController
      ..removeListener(_onChanged)
      ..dispose();
    _answerController
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

    final category = widget.categories.firstWhere(
      (item) => item.id == _selectedCategoryId,
      orElse: () => const FaqCategoryOption(id: '', label: ''),
    );

    Navigator.of(context).pop(
      FaqDialogResult(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        categoryId: category.id,
        categoryLabel: category.label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableHeight = MediaQuery.sizeOf(context).height - 64;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 760,
            maxHeight: availableHeight,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 40,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _DialogHeader(onClose: _close, isEditing: _isEditing),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      color: const Color(0xFFF8FAFC),
                      padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                      child: Column(
                        children: [
                          _CardSection(
                            title: 'Configuração da FAQ',
                            child: Column(
                              children: [
                                _DialogField(
                                  label: 'Pergunta',
                                  child: _DialogInput(
                                    controller: _questionController,
                                    hintText:
                                        'Ex: Como posso cancelar uma sessão marcada?',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _DialogField(
                                  label: 'Categoria da FAQ',
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _selectedCategoryId,
                                    onChanged: (value) {
                                      if (value == null) {
                                        return;
                                      }

                                      setState(() => _selectedCategoryId = value);
                                    },
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    decoration: _inputDecoration(),
                                    items: [
                                      for (final category in widget.categories)
                                        DropdownMenuItem<String>(
                                          value: category.id,
                                          child: Text(category.label),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _CardSection(
                            title: 'Resposta',
                            child: TextField(
                              controller: _answerController,
                              maxLines: 9,
                              minLines: 7,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                hintText:
                                    'Escreva aqui a resposta detalhada que ficará visível para os utilizadores no centro de ajuda.',
                                hintStyle: TextStyle(
                                  color: Color(0xFFD1D5DC),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _DialogFooter(
                  canSubmit: _canSubmit,
                  onCancel: _close,
                  onSubmit: _submit,
                  isEditing: _isEditing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose, required this.isEditing});

  final VoidCallback onClose;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
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
                        Icons.help_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEditing ? 'Editar FAQ' : 'Criar nova FAQ',
                        style: const TextStyle(
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
                Text(
                  isEditing
                      ? 'Atualize a pergunta, a categoria e a resposta desta FAQ.'
                      : 'Adicione uma nova pergunta frequente e publique-a no centro de ajuda.',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 25, 25, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFD1D5DC),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
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

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({
    required this.canSubmit,
    required this.onCancel,
    required this.onSubmit,
    required this.isEditing,
  });

  final bool canSubmit;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 28),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        spacing: 12,
        children: [
          TextButton(
            onPressed: onCancel,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
            child: ElevatedButton(
              onPressed: canSubmit ? onSubmit : null,
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
              child: Text(isEditing ? 'Atualizar FAQ' : 'Criar FAQ'),
            ),
          ),
        ],
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
