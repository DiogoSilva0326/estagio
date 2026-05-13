import 'package:flutter/material.dart';

import '../../../core/utils/csv_exporter.dart';
import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../models/pagamento_export_request.dart';
import '../models/pagamento_item.dart';
import '../services/backoffice_pagamentos_service.dart';
import '../sections/pagamentos_overview_section.dart';
import '../widgets/export_report_dialog.dart';

class PagamentosPage extends StatefulWidget {
  const PagamentosPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<PagamentosPage> createState() => _PagamentosPageState();
}

class _PagamentosPageState extends State<PagamentosPage> {
  final BackofficePagamentosService _service = BackofficePagamentosService();
  final Set<String> _selectedIds = <String>{};

  String _volumeTotalMes = '€ 0.00';
  String _comissoesPlataforma = '€ 0.00';
  String _payoutsPendentes = '€ 0.00';
  List<PagamentoItem> _items = const [];
  bool _loading = true;
  String? _warningMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _service.fetchOverview();
      if (!mounted) {
        return;
      }

      setState(() {
        _volumeTotalMes = data.volumeTotalMes;
        _comissoesPlataforma = data.comissoesPlataforma;
        _payoutsPendentes = data.payoutsPendentes;
        _items = data.transactions;
        _selectedIds.removeWhere(
          (id) => !data.transactions.any((item) => item.id == id),
        );
        _loading = false;
        _warningMessage = data.transactions.isEmpty
            ? 'Ainda não existem pagamentos registados para apresentar.'
            : null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _warningMessage =
            'Não foi possível carregar pagamentos e faturação neste momento.';
      });
    }
  }

  Future<void> _openExportDialog() async {
    if (_items.isEmpty) {
      return;
    }

    final professors = _items
        .map((item) => item.explicador)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final students = _items
        .map((item) => item.aluno)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final years = _items
        .map((item) => item.paymentDate?.year)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    await showDialog<void>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (_) => ExportReportDialog(
        availableProfessors: professors,
        availableStudents: students,
        availableYears: years,
        selectedCount: _selectedIds.length,
        totalCount: _items.length,
        onConfirm: _exportReport,
      ),
    );
  }

  Future<void> _exportReport(PagamentoExportRequest request) async {
    final itemsToExport = _resolveItemsForExport(request);
    if (itemsToExport.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Não existem transações para o filtro selecionado.'),
          ),
        );
      return;
    }

    final fileName =
        'pagamentos_${DateTime.now().millisecondsSinceEpoch}.csv';

    try {
      final location = await exportCsvFile(
        fileName: fileName,
        content: _buildCsv(itemsToExport),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Relatório exportado com sucesso para $location.'),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Não foi possível exportar o relatório. $error'),
          ),
        );
    }
  }

  List<PagamentoItem> _resolveItemsForExport(PagamentoExportRequest request) {
    switch (request.scope) {
      case PagamentoExportScope.selecionadas:
        return _items
            .where((item) => _selectedIds.contains(item.id))
            .toList(growable: false);
      case PagamentoExportScope.todas:
        return List<PagamentoItem>.from(_items, growable: false);
      case PagamentoExportScope.professor:
        final professor = request.professor?.trim().toLowerCase();
        return _items
            .where((item) => item.explicador.trim().toLowerCase() == professor)
            .toList(growable: false);
      case PagamentoExportScope.aluno:
        final aluno = request.aluno?.trim().toLowerCase();
        return _items
            .where((item) => item.aluno.trim().toLowerCase() == aluno)
            .toList(growable: false);
      case PagamentoExportScope.periodo:
        return _items.where((item) {
          final paymentDate = item.paymentDate;
          if (paymentDate == null) {
            return false;
          }

          final matchesMonth =
              request.month == null || paymentDate.month == request.month;
          final matchesYear =
              request.year == null || paymentDate.year == request.year;
          return matchesMonth && matchesYear;
        }).toList(growable: false);
    }
  }

  String _buildCsv(List<PagamentoItem> items) {
    final rows = <List<String>>[
      <String>[
        'Codigo',
        'Referencia',
        'Disciplina',
        'Data',
        'Aluno',
        'Professor',
        'ValorTotal',
        'ComissaoPlataforma',
        'ValorProfessor',
        'Estado',
        'Moeda',
      ],
      ...items.map(
        (item) => <String>[
          item.code,
          item.reference,
          item.subject,
          item.paymentDate?.toIso8601String() ?? '',
          item.aluno,
          item.explicador,
          item.grossAmountValue.toStringAsFixed(2),
          item.platformFeeAmountValue.toStringAsFixed(2),
          item.teacherAmountValue.toStringAsFixed(2),
          item.statusLabel,
          item.currency,
        ],
      ),
    ];

    return rows
        .map((row) => row.map(_escapeCsvValue).join(','))
        .join('\n');
  }

  String _escapeCsvValue(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  void _onSelectionChanged(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _onSelectAll(bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.addAll(_items.map((item) => item.id));
      } else {
        _selectedIds.removeAll(_items.map((item) => item.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.pagamentos,
      title: 'Pagamentos & Faturação',
      showTopBar: false,
      body: _PagamentosBody(
        volumeTotalMes: _volumeTotalMes,
        comissoesPlataforma: _comissoesPlataforma,
        payoutsPendentes: _payoutsPendentes,
        items: _items,
        isLoading: _loading,
        warningMessage: _warningMessage,
        selectedIds: _selectedIds,
        onSelectionChanged: _onSelectionChanged,
        onSelectAll: _onSelectAll,
        onExportPressed: _openExportDialog,
      ),
    );
  }
}

class _PagamentosBody extends StatelessWidget {
  const _PagamentosBody({
    required this.volumeTotalMes,
    required this.comissoesPlataforma,
    required this.payoutsPendentes,
    required this.items,
    required this.isLoading,
    required this.warningMessage,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onSelectAll,
    required this.onExportPressed,
  });

  final String volumeTotalMes;
  final String comissoesPlataforma;
  final String payoutsPendentes;
  final List<PagamentoItem> items;
  final bool isLoading;
  final String? warningMessage;
  final Set<String> selectedIds;
  final void Function(String id, bool selected) onSelectionChanged;
  final ValueChanged<bool> onSelectAll;
  final VoidCallback onExportPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;
        final verticalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;

        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              verticalPadding,
              horizontalPadding,
              verticalPadding,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: PagamentosPage._contentMaxWidth,
              ),
              child: PagamentosOverviewSection(
                volumeTotalMes: volumeTotalMes,
                comissoesPlataforma: comissoesPlataforma,
                payoutsPendentes: payoutsPendentes,
                items: items,
                isLoading: isLoading,
                warningMessage: warningMessage,
                selectedIds: selectedIds,
                onSelectionChanged: onSelectionChanged,
                onSelectAll: onSelectAll,
                onExportPressed: onExportPressed,
              ),
            ),
          ),
        );
      },
    );
  }
}
