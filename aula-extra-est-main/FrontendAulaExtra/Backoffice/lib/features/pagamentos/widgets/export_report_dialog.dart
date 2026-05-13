import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../models/pagamento_export_request.dart';

class ExportReportDialog extends StatefulWidget {
  const ExportReportDialog({
    required this.availableProfessors,
    required this.availableStudents,
    required this.availableYears,
    required this.selectedCount,
    required this.totalCount,
    required this.onConfirm,
    super.key,
  });

  final List<String> availableProfessors;
  final List<String> availableStudents;
  final List<int> availableYears;
  final int selectedCount;
  final int totalCount;
  final Future<void> Function(PagamentoExportRequest request) onConfirm;

  @override
  State<ExportReportDialog> createState() => _ExportReportDialogState();
}

class _ExportReportDialogState extends State<ExportReportDialog> {
  static const Map<int, String> _monthLabels = <int, String>{
    1: 'Janeiro',
    2: 'Fevereiro',
    3: 'Março',
    4: 'Abril',
    5: 'Maio',
    6: 'Junho',
    7: 'Julho',
    8: 'Agosto',
    9: 'Setembro',
    10: 'Outubro',
    11: 'Novembro',
    12: 'Dezembro',
  };

  PagamentoExportScope _scope = PagamentoExportScope.selecionadas;
  String? _selectedProfessor;
  String? _selectedStudent;
  int? _selectedMonth;
  int? _selectedYear;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCount == 0) {
      _scope = PagamentoExportScope.todas;
    }
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                _ExportReportHeader(selectedCount: widget.selectedCount),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoBanner(
                        label:
                            'Transações disponíveis: ${widget.totalCount} | Selecionadas: ${widget.selectedCount}',
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<PagamentoExportScope>(
                        initialValue: _scope,
                        decoration: _inputDecoration('Âmbito da exportação'),
                        items: [
                          DropdownMenuItem(
                            value: PagamentoExportScope.selecionadas,
                            enabled: widget.selectedCount > 0,
                            child: Text(
                              widget.selectedCount > 0
                                  ? 'Linhas selecionadas'
                                  : 'Linhas selecionadas (indisponível)',
                            ),
                          ),
                          const DropdownMenuItem(
                            value: PagamentoExportScope.todas,
                            child: Text('Todas as transações'),
                          ),
                          const DropdownMenuItem(
                            value: PagamentoExportScope.professor,
                            child: Text('Transações de um professor'),
                          ),
                          const DropdownMenuItem(
                            value: PagamentoExportScope.aluno,
                            child: Text('Transações de um aluno'),
                          ),
                          const DropdownMenuItem(
                            value: PagamentoExportScope.periodo,
                            child: Text('Transações de um mês/ano'),
                          ),
                        ],
                        onChanged: _submitting
                            ? null
                            : (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _scope = value;
                                });
                              },
                      ),
                      if (_scope == PagamentoExportScope.professor) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedProfessor,
                          decoration: _inputDecoration('Professor'),
                          items: widget.availableProfessors
                              .map(
                                (name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _submitting
                              ? null
                              : (value) => setState(() {
                                  _selectedProfessor = value;
                                }),
                        ),
                      ],
                      if (_scope == PagamentoExportScope.aluno) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedStudent,
                          decoration: _inputDecoration('Aluno'),
                          items: widget.availableStudents
                              .map(
                                (name) => DropdownMenuItem(
                                  value: name,
                                  child: Text(name),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _submitting
                              ? null
                              : (value) => setState(() {
                                  _selectedStudent = value;
                                }),
                        ),
                      ],
                      if (_scope == PagamentoExportScope.periodo) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _selectedMonth,
                                decoration: _inputDecoration('Mês'),
                                items: _monthLabels.entries
                                    .map(
                                      (entry) => DropdownMenuItem<int>(
                                        value: entry.key,
                                        child: Text(entry.value),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: _submitting
                                    ? null
                                    : (value) => setState(() {
                                        _selectedMonth = value;
                                      }),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                initialValue: _selectedYear,
                                decoration: _inputDecoration('Ano'),
                                items: widget.availableYears
                                    .map(
                                      (year) => DropdownMenuItem<int>(
                                        value: year,
                                        child: Text(year.toString()),
                                      ),
                                    )
                                    .toList(growable: false),
                                onChanged: _submitting
                                    ? null
                                    : (value) => setState(() {
                                        _selectedYear = value;
                                      }),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      _ExportReportFooter(
                        submitting: _submitting,
                        onCancel: () => Navigator.of(context).pop(),
                        onConfirm: _handleConfirm,
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFC9039), width: 1.4),
      ),
    );
  }

  Future<void> _handleConfirm() async {
    if (_scope == PagamentoExportScope.professor && _selectedProfessor == null) {
      return;
    }
    if (_scope == PagamentoExportScope.aluno && _selectedStudent == null) {
      return;
    }
    if (_scope == PagamentoExportScope.periodo &&
        _selectedMonth == null &&
        _selectedYear == null) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      await widget.onConfirm(
        PagamentoExportRequest(
          scope: _scope,
          professor: _selectedProfessor,
          aluno: _selectedStudent,
          month: _selectedMonth,
          year: _selectedYear,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }
}

class _ExportReportHeader extends StatelessWidget {
  const _ExportReportHeader({required this.selectedCount});

  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final subtitle = selectedCount > 0
        ? 'Escolha como quer exportar as transações já carregadas do backend.'
        : 'Selecione um filtro para exportar o relatório de transações.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
              ),
            ),
            child: const Icon(
              Icons.file_upload_outlined,
              size: 21,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exportar relatório',
                    style: TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4492,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF4A5565),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _CloseButton(),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD39A)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFB54708),
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ExportReportFooter extends StatelessWidget {
  const _ExportReportFooter({
    required this.submitting,
    required this.onCancel,
    required this.onConfirm,
  });

  final bool submitting;
  final VoidCallback onCancel;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: OutlinedButton(
              onPressed: submitting ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF364153),
                side: const BorderSide(color: Color(0xFFD1D5DC)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3125,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFFF15C64), Color(0xFFFABD2D)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton(
              onPressed: submitting ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Transferir',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.3125,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.close_rounded,
          size: 20,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
