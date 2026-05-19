import '../payment_status.dart';

class ProfessorPaymentHistoryItemDto {
  const ProfessorPaymentHistoryItemDto({
    required this.id,
    required this.reservationId,
    required this.studentName,
    required this.subject,
    required this.lessonTitle,
    required this.grossAmount,
    required this.platformFeeAmount,
    required this.netAmount,
    required this.status,
    required this.currency,
    required this.roleType,
    this.transactionId,
    this.lessonStart,
    this.lessonEnd,
    this.paymentDate,
    this.reference,
  });

  final String id;
  final String reservationId;
  final String? transactionId;
  final String studentName;
  final String subject;
  final String lessonTitle;
  final DateTime? lessonStart;
  final DateTime? lessonEnd;
  final DateTime? paymentDate;
  final double grossAmount;
  final double platformFeeAmount;
  final double netAmount;
  final String status;
  final String? reference;
  final String currency;
  final String roleType;

  bool get isPaid {
    return isPaidPaymentStatus(status);
  }

  factory ProfessorPaymentHistoryItemDto.fromJson(Map<String, dynamic> json) {
    String asString(dynamic value) => value?.toString() ?? '';

    DateTime? asDate(dynamic value) {
      if (value is! String || value.trim().isEmpty) return null;
      return DateTime.tryParse(value)?.toLocal();
    }

    double asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    return ProfessorPaymentHistoryItemDto(
      id: asString(json['id']),
      reservationId: asString(json['reservationId']),
      transactionId: json['transactionId']?.toString(),
      studentName: asString(json['studentName']).trim(),
      subject: asString(json['subject']).trim(),
      lessonTitle: asString(json['lessonTitle']).trim(),
      lessonStart: asDate(json['lessonStart']),
      lessonEnd: asDate(json['lessonEnd']),
      paymentDate: asDate(json['paymentDate']),
      grossAmount: asDouble(json['grossAmount']),
      platformFeeAmount: asDouble(json['platformFeeAmount']),
      netAmount: asDouble(json['netAmount']),
      status: asString(json['status']).trim(),
      reference: (json['reference']?.toString().trim().isEmpty ?? true)
          ? null
          : json['reference'].toString().trim(),
      currency: (json['currency']?.toString().trim().isEmpty ?? true)
          ? 'EUR'
          : json['currency'].toString().trim(),
        roleType: (json['roleType'] ??
              json['supportType'] ??
              json['targetRole'] ??
              json['professionalRole'] ??
              json['role'])
            ?.toString()
            .trim() ??
          '',
    );
  }
}

class ProfessorPaymentSummaryDto {
  const ProfessorPaymentSummaryDto({
    required this.totalReceived,
    required this.pendingAmount,
    required this.totalThisMonth,
    required this.transactionsCount,
    required this.currency,
    required this.history,
  });

  final double totalReceived;
  final double pendingAmount;
  final double totalThisMonth;
  final int transactionsCount;
  final String currency;
  final List<ProfessorPaymentHistoryItemDto> history;

  factory ProfessorPaymentSummaryDto.fromJson(Map<String, dynamic> json) {
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
        ? rawHistory
              .whereType<Map<String, dynamic>>()
              .map(ProfessorPaymentHistoryItemDto.fromJson)
              .toList()
        : <ProfessorPaymentHistoryItemDto>[];

    return ProfessorPaymentSummaryDto(
      totalReceived: asDouble(json['totalReceived']),
      pendingAmount: asDouble(json['pendingAmount']),
      totalThisMonth: asDouble(json['totalThisMonth']),
      transactionsCount: asInt(json['transactionsCount']),
      currency: (json['currency']?.toString().trim().isEmpty ?? true)
          ? 'EUR'
          : json['currency'].toString().trim(),
      history: history,
    );
  }
}

class ProfessorPaymentDetailsDto {
  const ProfessorPaymentDetailsDto({
    required this.id,
    required this.reservationId,
    required this.studentName,
    required this.subject,
    required this.lessonTitle,
    required this.grossAmount,
    required this.platformFeeAmount,
    required this.netAmount,
    required this.status,
    required this.currency,
    this.transactionId,
    this.studentEmail,
    this.lessonStart,
    this.lessonEnd,
    this.paymentDate,
    this.commissionPercent,
    this.fixedFee,
    this.reference,
    this.receiptUrl,
  });

  final String id;
  final String reservationId;
  final String? transactionId;
  final String studentName;
  final String? studentEmail;
  final String subject;
  final String lessonTitle;
  final DateTime? lessonStart;
  final DateTime? lessonEnd;
  final DateTime? paymentDate;
  final double grossAmount;
  final double platformFeeAmount;
  final double netAmount;
  final double? commissionPercent;
  final double? fixedFee;
  final String status;
  final String? reference;
  final String? receiptUrl;
  final String currency;

  factory ProfessorPaymentDetailsDto.fromJson(Map<String, dynamic> json) {
    String asString(dynamic value) => value?.toString() ?? '';

    DateTime? asDate(dynamic value) {
      if (value is! String || value.trim().isEmpty) return null;
      return DateTime.tryParse(value)?.toLocal();
    }

    double asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    double? asNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return ProfessorPaymentDetailsDto(
      id: asString(json['id']),
      reservationId: asString(json['reservationId']),
      transactionId: json['transactionId']?.toString(),
      studentName: asString(json['studentName']).trim(),
      studentEmail: (json['studentEmail']?.toString().trim().isEmpty ?? true)
          ? null
          : json['studentEmail'].toString().trim(),
      subject: asString(json['subject']).trim(),
      lessonTitle: asString(json['lessonTitle']).trim(),
      lessonStart: asDate(json['lessonStart']),
      lessonEnd: asDate(json['lessonEnd']),
      paymentDate: asDate(json['paymentDate']),
      grossAmount: asDouble(json['grossAmount']),
      platformFeeAmount: asDouble(json['platformFeeAmount']),
      netAmount: asDouble(json['netAmount']),
      commissionPercent: asNullableDouble(json['commissionPercent']),
      fixedFee: asNullableDouble(json['fixedFee']),
      status: asString(json['status']).trim(),
      reference: (json['reference']?.toString().trim().isEmpty ?? true)
          ? null
          : json['reference'].toString().trim(),
      receiptUrl: (json['receiptUrl']?.toString().trim().isEmpty ?? true)
          ? null
          : json['receiptUrl'].toString().trim(),
      currency: (json['currency']?.toString().trim().isEmpty ?? true)
          ? 'EUR'
          : json['currency'].toString().trim(),
    );
  }
}
