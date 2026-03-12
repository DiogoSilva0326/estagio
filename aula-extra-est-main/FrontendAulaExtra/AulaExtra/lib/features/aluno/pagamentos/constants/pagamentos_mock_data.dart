import 'package:flutter/material.dart';

/// Modelo de uma linha/transação na tabela/lista de pagamentos do aluno.
///
/// Onde é usado:
/// - Em `lib/features/aluno/pagamentos/` para renderizar cada pagamento.
class PagamentoRowData {
  const PagamentoRowData({
    required this.tutor,
    required this.disciplina,
    required this.data,
    required this.valor,
    required this.status,
    required this.isPago,
    required this.receiptIcon,
  });

  final String tutor;
  final String disciplina;
  final String data;
  final String valor;
  final String status;
  final bool isPago;
  final IconData receiptIcon;
}

/// Dados fake de pagamentos para preencher a UI durante prototipagem/dev.
///
/// Onde é usado:
/// - Em `lib/features/aluno/pagamentos/` enquanto a integração com backend não existe.
class PagamentosMockData {
  const PagamentosMockData._();

  /// Total gasto (badge/resumo).
  static const totalGasto = '138€';

  /// Total pendente (badge/resumo).
  static const pendente = '30€';

  /// Número de transações (badge/resumo).
  static const transacoes = '5';

  /// Linhas de exemplo da lista de pagamentos.
  static const rows = <PagamentoRowData>[
    PagamentoRowData(
      tutor: 'João Silva',
      disciplina: 'Matemática',
      data: '20 Jan 2026',
      valor: '25€',
      status: 'Pago',
      isPago: true,
      receiptIcon: Icons.receipt_long_rounded,
    ),
    PagamentoRowData(
      tutor: 'Maria Santos',
      disciplina: 'Física',
      data: '22 Jan 2026',
      valor: '30€',
      status: 'Pago',
      isPago: true,
      receiptIcon: Icons.receipt_long_rounded,
    ),
    PagamentoRowData(
      tutor: 'Pedro Costa',
      disciplina: 'Inglês',
      data: '23 Jan 2026',
      valor: '28€',
      status: 'Pago',
      isPago: true,
      receiptIcon: Icons.receipt_long_rounded,
    ),
    PagamentoRowData(
      tutor: 'Ana Rodrigues',
      disciplina: 'Matemática',
      data: '24 Jan 2026',
      valor: '25€',
      status: 'Pago',
      isPago: true,
      receiptIcon: Icons.receipt_long_rounded,
    ),
    PagamentoRowData(
      tutor: 'Carlos Ferreira',
      disciplina: 'Física',
      data: '28 Jan 2026',
      valor: '30€',
      status: 'Pendente',
      isPago: false,
      receiptIcon: Icons.receipt_long_rounded,
    ),
  ];
}
