import '../payment_status.dart';

class PaymentHistoryItemDto {
  const PaymentHistoryItemDto({
    required this.id,
    required this.paymentSource,
    required this.tutorName,
    required this.subject,
    required this.amount,
    required this.status,
    this.date,
    this.receiptUrl,
    this.reference,
  });

  final String id;
  final String paymentSource;
  final String tutorName;
  final String subject;
  final DateTime? date;
  final double amount;
  final String status;
  final String? receiptUrl;
  final String? reference;

  bool get isPaid {
    return isPaidPaymentStatus(status);
  }

  factory PaymentHistoryItemDto.fromJson(Map<String, dynamic> json) {
    String asString(dynamic value) => value?.toString() ?? '';

    DateTime? asDate(dynamic value) {
      if (value is! String || value.trim().isEmpty) return null;
      return DateTime.tryParse(value);
    }

    double asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return PaymentHistoryItemDto(
      id: asString(json['id']),
      paymentSource: asString(json['paymentSource']).trim().isEmpty
          ? 'reservation_payment'
          : asString(json['paymentSource']).trim(),
      tutorName: asString(json['tutorName']).trim(),
      subject: asString(json['subject']).trim(),
      date: asDate(json['date']),
      amount: asDouble(json['amount']),
      status: asString(json['status']).trim(),
      receiptUrl: (json['receiptUrl']?.toString().trim().isEmpty ?? true) ? null : json['receiptUrl'].toString().trim(),
      reference: (json['reference']?.toString().trim().isEmpty ?? true) ? null : json['reference'].toString().trim(),
    );
  }
}

class PaymentSummaryDto {
  const PaymentSummaryDto({
    required this.availableCredits,
    required this.totalSpent,
    required this.pendingAmount,
    required this.transactionsCount,
    required this.currency,
    required this.history,
  });

  final double availableCredits;
  final double totalSpent;
  final double pendingAmount;
  final int transactionsCount;
  final String currency;
  final List<PaymentHistoryItemDto> history;

  factory PaymentSummaryDto.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int asInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    final rawHistory = json['history'];
    final history = rawHistory is List
        ? rawHistory.whereType<Map<String, dynamic>>().map(PaymentHistoryItemDto.fromJson).toList()
        : <PaymentHistoryItemDto>[];

    return PaymentSummaryDto(
      availableCredits: asDouble(json['availableCredits']),
      totalSpent: asDouble(json['totalSpent']),
      pendingAmount: asDouble(json['pendingAmount']),
      transactionsCount: asInt(json['transactionsCount']),
      currency: (json['currency']?.toString().trim().isEmpty ?? true) ? 'EUR' : json['currency'].toString().trim(),
      history: history,
    );
  }
}