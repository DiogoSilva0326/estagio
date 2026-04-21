import '../models/pagamento_item.dart';

class PagamentosMockData {
  const PagamentosMockData._();

  static const String volumeTotalMes = '€ 62.250';
  static const String comissoesPlataforma = '€ 12.450';
  static const String payoutsPendentes = '€ 4.520';

  static const List<PagamentoItem> transactions = [
    PagamentoItem(
      code: '#TRX-992',
      dateLabel: '13 Abr',
      aluno: 'Tiago Mendes',
      explicador: 'Ana Rodrigues',
      totalAmount: '€25.00',
      commissionLabel: '€5.00 (20%)',
      teacherAmount: '€20.00',
      status: PagamentoStatus.pago,
    ),
    PagamentoItem(
      code: '#TRX-991',
      dateLabel: '12 Abr',
      aluno: 'Sofia Almeida',
      explicador: 'Carlos Ferreira',
      totalAmount: '€30.00',
      commissionLabel: '€6.00 (20%)',
      teacherAmount: '€24.00',
      status: PagamentoStatus.pendente,
    ),
    PagamentoItem(
      code: '#TRX-990',
      dateLabel: '11 Abr',
      aluno: 'Mariana Costa',
      explicador: 'Pedro Santos',
      totalAmount: '€40.00',
      commissionLabel: '€8.00 (20%)',
      teacherAmount: '€32.00',
      status: PagamentoStatus.pago,
    ),
    PagamentoItem(
      code: '#TRX-989',
      dateLabel: '10 Abr',
      aluno: 'João Ribeiro',
      explicador: 'Beatriz Lopes',
      totalAmount: '€22.00',
      commissionLabel: '€4.40 (20%)',
      teacherAmount: '€17.60',
      status: PagamentoStatus.emProcessamento,
    ),
  ];
}
