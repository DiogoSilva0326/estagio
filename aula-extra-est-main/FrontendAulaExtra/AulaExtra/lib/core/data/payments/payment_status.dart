String normalizePaymentStatus(String? status) {
  final normalized = status?.trim().toLowerCase() ?? '';

  if (normalized.contains('refund') ||
      normalized.contains('devolv') ||
      normalized.contains('reembols')) {
    return 'refunded';
  }

  if (normalized.contains('paid') ||
      normalized.contains('pago') ||
      normalized.contains('success') ||
      normalized.contains('completed') ||
      normalized.contains('conclu')) {
    return 'paid';
  }

  return 'pending';
}

bool isRefundedPaymentStatus(String? status) =>
    normalizePaymentStatus(status) == 'refunded';

bool isPaidPaymentStatus(String? status) => normalizePaymentStatus(status) == 'paid';

String paymentStatusLabel(String? status) {
  switch (normalizePaymentStatus(status)) {
    case 'refunded':
      return 'Devolvido';
    case 'paid':
      return 'Pago';
    default:
      return 'Pendente';
  }
}