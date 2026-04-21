import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';

enum NewsletterCampaignDialogAction { draft, send }

class NewsletterCampaignDialogResult {
  const NewsletterCampaignDialogResult({
    required this.internalName,
    required this.emailSubject,
    required this.audience,
    required this.emailBody,
    required this.action,
  });

  final String internalName;
  final String emailSubject;
  final String audience;
  final String emailBody;
  final NewsletterCampaignDialogAction action;
}

class NewsletterCampaignDialog extends StatefulWidget {
  const NewsletterCampaignDialog({super.key});

  @override
  State<NewsletterCampaignDialog> createState() =>
      _NewsletterCampaignDialogState();
}

class _NewsletterCampaignDialogState extends State<NewsletterCampaignDialog> {
  static const List<String> _audienceOptions = [
    'Novos registos',
    'Alunos inativos há 30 dias',
    'Explicadores ativos',
    'Leads do formulário principal',
  ];

  late final TextEditingController _internalNameController;
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;
  String _selectedAudience = _audienceOptions.first;

  bool get _canSubmit =>
      _internalNameController.text.trim().isNotEmpty &&
      _subjectController.text.trim().isNotEmpty &&
      _bodyController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _internalNameController = TextEditingController()..addListener(_onChanged);
    _subjectController = TextEditingController()..addListener(_onChanged);
    _bodyController = TextEditingController()..addListener(_onChanged);
  }

  @override
  void dispose() {
    _internalNameController
      ..removeListener(_onChanged)
      ..dispose();
    _subjectController
      ..removeListener(_onChanged)
      ..dispose();
    _bodyController
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _close() => Navigator.of(context).pop();

  void _submit(NewsletterCampaignDialogAction action) {
    if (!_canSubmit) {
      return;
    }

    Navigator.of(context).pop(
      NewsletterCampaignDialogResult(
        internalName: _internalNameController.text.trim(),
        emailSubject: _subjectController.text.trim(),
        audience: _selectedAudience,
        emailBody: _bodyController.text.trim(),
        action: action,
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
          constraints: const BoxConstraints(maxWidth: 700),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogHeader(onClose: _close),
                Container(
                  width: double.infinity,
                  color: const Color(0xFFF8FAFC),
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                  child: Column(
                    children: [
                      _ConfigurationCard(
                        internalNameController: _internalNameController,
                        subjectController: _subjectController,
                        selectedAudience: _selectedAudience,
                        audienceOptions: _audienceOptions,
                        onAudienceChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() => _selectedAudience = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      _EmailBodyCard(bodyController: _bodyController),
                    ],
                  ),
                ),
                _DialogFooter(
                  canSubmit: _canSubmit,
                  onCancel: _close,
                  onSaveDraft: () =>
                      _submit(NewsletterCampaignDialogAction.draft),
                  onSend: () => _submit(NewsletterCampaignDialogAction.send),
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
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

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
                        color: const Color(0xFFFB7B02),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.campaign_outlined,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Nova Campanha de Newsletter',
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
                  'Crie e configure uma nova newsletter para a sua base.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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

class _ConfigurationCard extends StatelessWidget {
  const _ConfigurationCard({
    required this.internalNameController,
    required this.subjectController,
    required this.selectedAudience,
    required this.audienceOptions,
    required this.onAudienceChanged,
  });

  final TextEditingController internalNameController;
  final TextEditingController subjectController;
  final String selectedAudience;
  final List<String> audienceOptions;
  final ValueChanged<String?> onAudienceChanged;

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      title: 'Configuração',
      child: Column(
        children: [
          _DialogField(
            label: 'Nome Interno da Campanha',
            child: _DialogInput(
              controller: internalNameController,
              hintText: 'Ex: Promoção Exames Nacionais 2026',
            ),
          ),
          const SizedBox(height: 16),
          _DialogField(
            label: 'Assunto do Email',
            child: _DialogInput(
              controller: subjectController,
              hintText: 'Ex: Prepara-te para os exames com 20% de desconto! 🚀',
            ),
          ),
          const SizedBox(height: 16),
          _DialogField(
            label: 'Destinatários',
            child: DropdownButtonFormField<String>(
              initialValue: selectedAudience,
              onChanged: onAudienceChanged,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              decoration: _inputDecoration(),
              items: [
                for (final option in audienceOptions)
                  DropdownMenuItem<String>(value: option, child: Text(option)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailBodyCard extends StatelessWidget {
  const _EmailBodyCard({required this.bodyController});

  final TextEditingController bodyController;

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      removePadding: true,
      title: 'Corpo do Email',
      child: Column(
        children: [
          const _EditorToolbar(),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              controller: bodyController,
              maxLines: 10,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText:
                    'Começa a escrever o conteúdo da tua newsletter aqui... Podes utilizar tags como {{Nome_do_Aluno}} para personalizar a mensagem.',
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
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({
    required this.title,
    required this.child,
    this.removePadding = false,
  });

  final String title;
  final Widget child;
  final bool removePadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: removePadding
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(25, 25, 25, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: removePadding
                ? const EdgeInsets.fromLTRB(16, 16, 16, 0)
                : EdgeInsets.zero,
            child: Row(
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
          ),
          SizedBox(height: removePadding ? 16 : 20),
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
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: AppColors.textMuted,
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
    ),
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.accent),
    ),
  );
}

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const [
          _ToolbarButton(icon: Icons.format_bold_rounded),
          _ToolbarDivider(),
          _ToolbarButton(icon: Icons.format_italic_rounded),
          _ToolbarButton(icon: Icons.format_underlined_rounded),
          _ToolbarDivider(),
          _ToolbarButton(icon: Icons.format_list_bulleted_rounded),
          _ToolbarButton(icon: Icons.format_list_numbered_rounded),
          _ToolbarDivider(),
          _ToolbarButton(icon: Icons.link_rounded),
          _ToolbarButton(icon: Icons.image_outlined),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        onPressed: () {},
        splashRadius: 18,
        icon: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ToolbarDivider extends StatelessWidget {
  const _ToolbarDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 16, color: const Color(0xFFE5E7EB));
  }
}

class _DialogFooter extends StatelessWidget {
  const _DialogFooter({
    required this.canSubmit,
    required this.onCancel,
    required this.onSaveDraft,
    required this.onSend,
  });

  final bool canSubmit;
  final VoidCallback onCancel;
  final VoidCallback onSaveDraft;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 560) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CancelButton(onPressed: onCancel),
                const SizedBox(height: 12),
                _SecondaryActionButton(
                  label: 'Guardar Rascunho',
                  icon: Icons.inventory_2_outlined,
                  onPressed: canSubmit ? onSaveDraft : null,
                ),
                const SizedBox(height: 12),
                _PrimaryActionButton(
                  label: 'Enviar Campanha',
                  icon: Icons.send_rounded,
                  onPressed: canSubmit ? onSend : null,
                ),
              ],
            );
          }

          return Row(
            children: [
              _CancelButton(onPressed: onCancel),
              const Spacer(),
              SizedBox(
                width: 217,
                child: _SecondaryActionButton(
                  label: 'Guardar Rascunho',
                  icon: Icons.inventory_2_outlined,
                  onPressed: canSubmit ? onSaveDraft : null,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 207,
                child: _PrimaryActionButton(
                  label: 'Enviar Campanha',
                  icon: Icons.send_rounded,
                  onPressed: canSubmit ? onSend : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
      child: const Text(
        'Cancelar',
        style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF364153),
          side: const BorderSide(color: Color(0xFFD1D5DC)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: enabled
              ? const [Color(0xFFF15C64), Color(0xFFFC9039)]
              : const [Color(0xFFE5E7EB), Color(0xFFE5E7EB)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: enabled ? Colors.white : AppColors.textMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
