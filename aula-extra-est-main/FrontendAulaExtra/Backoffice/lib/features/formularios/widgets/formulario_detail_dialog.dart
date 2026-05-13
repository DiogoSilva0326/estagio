import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/formulario_item.dart';
import '../services/backoffice_formularios_service.dart';

class FormularioDetailDialog extends StatefulWidget {
  const FormularioDetailDialog({required this.item, super.key});

  final FormularioItem item;

  @override
  State<FormularioDetailDialog> createState() => _FormularioDetailDialogState();
}

class _FormularioDetailDialogState extends State<FormularioDetailDialog> {
  late final TextEditingController _responseController;
  final BackofficeFormulariosService _service = BackofficeFormulariosService();
  bool _submitting = false;
  String? _errorMessage;

  FormularioItem get item => widget.item;

  bool get _canReply => item.profileEmail.trim().isNotEmpty && item.profileEmail != 'Sem email disponível';

  @override
  void initState() {
    super.initState();
    _responseController = TextEditingController();
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(28),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFFFB7B02),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.formName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${item.id} · ${item.dateLabel}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoRow(label: 'Perfil', value: item.profileName),
                const SizedBox(height: 12),
                _InfoRow(label: 'Email', value: item.profileEmail),
                const SizedBox(height: 12),
                _InfoRow(label: 'Estado', value: item.statusLabel),
                const SizedBox(height: 20),
                const Text(
                  'Mensagem',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    item.message,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Responder',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _responseController,
                  minLines: 4,
                  maxLines: 6,
                  enabled: !_submitting && _canReply,
                  decoration: InputDecoration(
                    hintText: _canReply
                        ? 'Escreva aqui a resposta para enviar por email.'
                        : 'Não existe email disponível para responder a este formulário.',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFFC9039), width: 1.4),
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFB42318),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
                      child: const Text('Fechar'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _submitting ? null : _markAsRead,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFC9039),
                        side: const BorderSide(color: Color(0xFFFC9039)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Marcar como lida'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: _submitting ? null : _reply,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFC9039),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Responder'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _markAsRead() async {
    await _runAction(() => _service.markAsRead(item.submissionId));
  }

  Future<void> _reply() async {
    final responseMessage = _responseController.text.trim();
    if (!_canReply) {
      setState(() => _errorMessage = 'Este formulário não tem email disponível para resposta.');
      return;
    }
    if (responseMessage.isEmpty) {
      setState(() => _errorMessage = 'Escreva a resposta antes de enviar.');
      return;
    }

    await _runAction(() => _service.replyToSubmission(item.submissionId, responseMessage));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await action();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitting = false;
        _errorMessage = 'Não foi possível concluir a ação. $error';
      });
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
