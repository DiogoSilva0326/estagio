import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

class NovoPlanoDialogResult {
  const NovoPlanoDialogResult({
    required this.courseId,
    required this.name,
    required this.description,
    required this.price,
    required this.numberOfLessons,
    required this.isActive,
  });

  final String courseId;
  final String name;
  final String description;
  final String price;
  final int numberOfLessons;
  final bool isActive;
}

class NovoPlanoDialogCourseOption {
  const NovoPlanoDialogCourseOption({required this.id, required this.name});

  final String id;
  final String name;
}

class NovoPlanoDialog extends StatefulWidget {
  const NovoPlanoDialog({
    super.key,
    required this.courses,
    this.initialName,
    this.initialDescription,
    this.initialPrice,
    this.initialCourseId,
    this.initialNumberOfLessons,
    this.initialIsActive,
    this.submitLabel = 'Guardar plano',
    this.title = 'Novo Plano',
    this.subtitle = 'Crie um novo plano com nome, descrição e preço.',
  });

  final List<NovoPlanoDialogCourseOption> courses;
  final String? initialName;
  final String? initialDescription;
  final String? initialPrice;
  final String? initialCourseId;
  final int? initialNumberOfLessons;
  final bool? initialIsActive;
  final String submitLabel;
  final String title;
  final String subtitle;

  @override
  State<NovoPlanoDialog> createState() => _NovoPlanoDialogState();
}

class _NovoPlanoDialogState extends State<NovoPlanoDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  String? _selectedCourseId;
  late final int _numberOfLessons;
  bool _isActive = true;

  bool get _canSubmit =>
      (_selectedCourseId?.isNotEmpty ?? false) &&
      _nameController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _priceController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '')
      ..addListener(_onChanged);
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    )..addListener(_onChanged);
    _priceController = TextEditingController(text: widget.initialPrice ?? '')
      ..addListener(_onChanged);
    _selectedCourseId =
        widget.initialCourseId ??
        (widget.courses.isNotEmpty ? widget.courses.first.id : null);
    _numberOfLessons = widget.initialNumberOfLessons ?? 1;
    _isActive = widget.initialIsActive ?? true;
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onChanged)
      ..dispose();
    _priceController
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _submit() {
    if (!_canSubmit) {
      return;
    }

    Navigator.of(context).pop(
      NovoPlanoDialogResult(
        courseId: _selectedCourseId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim(),
        numberOfLessons: _numberOfLessons,
        isActive: _isActive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 460, maxHeight: maxHeight),
          child: Container(
            padding: const EdgeInsets.all(32),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF2E8),
                                borderRadius: BorderRadius.circular(18.637),
                              ),
                              child: const Icon(
                                Icons.add_card_rounded,
                                size: 27.955,
                                color: Color(0xFFFB7B02),
                              ),
                            ),
                            const SizedBox(width: 18.637),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      color: Color(0xFF101828),
                                      fontSize: 20.966,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.5119,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.subtitle,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'NOME DO PLANO',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.813,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3563,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DialogTextField(
                          controller: _nameController,
                          hintText: 'Ex.: Pack Premium',
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'DESCRIÇÃO',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.813,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3563,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DialogTextField(
                          controller: _descriptionController,
                          hintText: 'Ex.: Acesso flexível com apoio prioritário.',
                          maxLines: 4,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'PREÇO',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12.813,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3563,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DialogTextField(
                          controller: _priceController,
                          hintText: 'Ex.: 49.99',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixText: '€ ',
                        ),
                        const SizedBox(height: 18),
                        SwitchListTile.adaptive(
                          value: _isActive,
                          onChanged: (value) => setState(() => _isActive = value),
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AppColors.accent,
                          title: const Text(
                            'Plano ativo',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15.143,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _canSubmit
                            ? const [Color(0xFFF15C64), Color(0xFFFABD2D)]
                            : const [Color(0xFFE5E7EB), Color(0xFFE5E7EB)],
                      ),
                      borderRadius: BorderRadius.circular(16.307),
                    ),
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.307),
                        ),
                      ),
                      child: Text(
                        widget.submitLabel,
                        style: TextStyle(
                          color: _canSubmit ? Colors.white : AppColors.textMuted,
                          fontSize: 16.307,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1752,
                        ),
                      ),
                    ),
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

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.prefixText,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? prefixText;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixText: prefixText,
        hintStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 15.143,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18.637,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.307),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.307),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15.143,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
