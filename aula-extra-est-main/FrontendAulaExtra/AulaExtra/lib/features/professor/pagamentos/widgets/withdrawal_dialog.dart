import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class WithdrawalDialog extends StatefulWidget {
  const WithdrawalDialog({super.key});

  @override
  State<WithdrawalDialog> createState() => _WithdrawalDialogState();
}

class _WithdrawalDialogState extends State<WithdrawalDialog> {
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _accountHolderController =
      TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _observationsController = TextEditingController();

  PlatformFile? _ibanProofFile;
  PlatformFile? _paymentReceiptFile;
  String? _localError;

  @override
  void dispose() {
    _ibanController.dispose();
    _accountHolderController.dispose();
    _bankNameController.dispose();
    _amountController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isIbanProof) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
      allowMultiple: false,
    );

    final selectedFile = result?.files.single;
    if (selectedFile == null || !mounted) return;

    setState(() {
      if (isIbanProof) {
        _ibanProofFile = selectedFile;
      } else {
        _paymentReceiptFile = selectedFile;
      }
      _localError = null;
    });
  }

  void _submit() {
    final iban = _ibanController.text.trim();
    final accountHolder = _accountHolderController.text.trim();
    final amount = _amountController.text.trim();

    if (iban.isEmpty ||
        accountHolder.isEmpty ||
        amount.isEmpty ||
        _ibanProofFile == null ||
        _paymentReceiptFile == null) {
      setState(() {
        _localError =
            'Preencha os campos obrigatórios e anexe os dois ficheiros.';
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Solicitar Saque',
                        style: TextStyle(
                          color: Color(0xFF101828),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(999),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          color: Color(0xFF667085),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _WithdrawalField(
                  label: 'IBAN *',
                  child: TextField(
                    controller: _ibanController,
                    decoration: _withdrawalInputDecoration(
                      hintText: 'PT50 0000 0000 0000 0000 0000 0',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _WithdrawalField(
                  label: 'Titular da Conta *',
                  child: TextField(
                    controller: _accountHolderController,
                    decoration: _withdrawalInputDecoration(
                      hintText: 'Nome completo',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _WithdrawalField(
                  label: 'Nome do Banco',
                  child: TextField(
                    controller: _bankNameController,
                    decoration: _withdrawalInputDecoration(
                      hintText: 'Ex: Banco CTT, Millennium BCP',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _WithdrawalField(
                  label: 'Valor do Saque *',
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _withdrawalInputDecoration(
                      hintText: '0.00',
                      suffixText: '€',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _UploadPickerCard(
                  label: 'Comprovante IBAN *',
                  selectedFileName: _ibanProofFile?.name,
                  onPickFile: () => _pickFile(true),
                ),
                const SizedBox(height: 20),
                _UploadPickerCard(
                  label: 'Comprovante de Pagamento *',
                  selectedFileName: _paymentReceiptFile?.name,
                  onPickFile: () => _pickFile(false),
                ),
                const SizedBox(height: 20),
                _WithdrawalField(
                  label: 'Observações',
                  child: TextField(
                    controller: _observationsController,
                    minLines: 4,
                    maxLines: 6,
                    decoration: _withdrawalInputDecoration(
                      hintText: 'Informações adicionais (opcional)',
                    ),
                  ),
                ),
                if (_localError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _localError!,
                    style: const TextStyle(
                      color: Color(0xFFB42318),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Color(0xFF344054),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              PagamentosProfessorColors.withdrawGradientTop,
                              PagamentosProfessorColors.withdrawGradientBottom,
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Solicitar Saque',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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
}

InputDecoration _withdrawalInputDecoration({
  required String hintText,
  String? suffixText,
}) {
  const borderColor = Color(0xFFD0D5DD);

  OutlineInputBorder buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }

  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF98A2B3),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    suffixText: suffixText,
    suffixStyle: const TextStyle(
      color: Color(0xFF344054),
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: buildBorder(borderColor),
    enabledBorder: buildBorder(borderColor),
    focusedBorder: buildBorder(PagamentosProfessorColors.withdrawGradientTop),
  );
}

class _WithdrawalField extends StatelessWidget {
  const _WithdrawalField({required this.label, required this.child});

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
            color: Color(0xFF344054),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _UploadPickerCard extends StatelessWidget {
  const _UploadPickerCard({
    required this.label,
    required this.onPickFile,
    this.selectedFileName,
  });

  final String label;
  final String? selectedFileName;
  final VoidCallback onPickFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF344054),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFD0D5DD)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  color: Color(0xFF667085),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Arraste e solte o arquivo aqui',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Formatos aceites: PDF, JPG, PNG',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'ou',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton(
                onPressed: onPickFile,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(180, 44),
                  side: const BorderSide(color: Color(0xFFD0D5DD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Escolher Arquivo',
                  style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (selectedFileName != null) ...[
                const SizedBox(height: 14),
                Text(
                  selectedFileName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF027A48),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
