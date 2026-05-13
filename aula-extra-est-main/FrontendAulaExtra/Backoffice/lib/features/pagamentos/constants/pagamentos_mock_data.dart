import '../models/pagamento_item.dart';

class PagamentosMockData {
  const PagamentosMockData._();

  static const String volumeTotalMes = '€ 62.250';
  static const String comissoesPlataforma = '€ 12.450';
  static const String payoutsPendentes = '€ 4.520';

  static const List<PagamentoItem> transactions = [
    PagamentoItem(
      id: 'trx-992',
      code: '#TRX-992',
      subject: 'Matemática',
      paymentDate: null,
      reference: 'TRX-992',
      currency: 'EUR',
      grossAmountValue: 25,
      platformFeeAmountValue: 5,
      teacherAmountValue: 20,
      dateLabel: '13 Abr',
      aluno: 'Tiago Mendes',
      explicador: 'Ana Rodrigues',
      totalAmount: '€25.00',
      commissionLabel: '€5.00 (20%)',
      teacherAmount: '€20.00',
      status: 'paid',
    ),
    PagamentoItem(
      id: 'trx-991',
      code: '#TRX-991',
      subject: 'Física',
      paymentDate: null,
      reference: 'TRX-991',
      currency: 'EUR',
      grossAmountValue: 30,
      platformFeeAmountValue: 6,
      teacherAmountValue: 24,
      dateLabel: '12 Abr',
      aluno: 'Sofia Almeida',
      explicador: 'Carlos Ferreira',
      totalAmount: '€30.00',
      commissionLabel: '€6.00 (20%)',
      teacherAmount: '€24.00',
      status: 'pending',
    ),
    PagamentoItem(
      id: 'trx-990',
      code: '#TRX-990',
      subject: 'Português',
      paymentDate: null,
      reference: 'TRX-990',
      currency: 'EUR',
      grossAmountValue: 40,
      platformFeeAmountValue: 8,
      teacherAmountValue: 32,
      dateLabel: '11 Abr',
      aluno: 'Mariana Costa',
      explicador: 'Pedro Santos',
      totalAmount: '€40.00',
      commissionLabel: '€8.00 (20%)',
      teacherAmount: '€32.00',
      status: 'paid',
    ),
    PagamentoItem(
      id: 'trx-989',
      code: '#TRX-989',
      subject: 'Química',
      paymentDate: null,
      reference: 'TRX-989',
      currency: 'EUR',
      grossAmountValue: 22,
      platformFeeAmountValue: 4.4,
      teacherAmountValue: 17.6,
      dateLabel: '10 Abr',
      aluno: 'João Ribeiro',
      explicador: 'Beatriz Lopes',
      totalAmount: '€22.00',
      commissionLabel: '€4.40 (20%)',
      teacherAmount: '€17.60',
      status: 'processing',
    ),
  ];
}
