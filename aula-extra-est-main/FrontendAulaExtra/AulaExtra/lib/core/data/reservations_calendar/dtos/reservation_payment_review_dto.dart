class ReservationPaymentReviewDto {
  const ReservationPaymentReviewDto({
    required this.reservationId,
    required this.lessonId,
    required this.reservationStatus,
    required this.lessonTitle,
    required this.subject,
    required this.tutoringTypeName,
    required this.teacherName,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.availableCredits,
    required this.currency,
    required this.canAfford,
    required this.alreadyPaid,
    this.reservationPaymentId,
    this.paymentStatus,
    this.platformFeeAmount = 0,
    this.teacherNetAmount = 0,
  });

  final String reservationId;
  final String lessonId;
  final String reservationStatus;
  final String lessonTitle;
  final String subject;
  final String tutoringTypeName;
  final String teacherName;
  final DateTime? startTime;
  final DateTime? endTime;
  final double amount;
  final double availableCredits;
  final String currency;
  final bool canAfford;
  final bool alreadyPaid;
  final String? reservationPaymentId;
  final String? paymentStatus;
  final double platformFeeAmount;
  final double teacherNetAmount;

  factory ReservationPaymentReviewDto.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic value) {
      if (value == null) return 0;
      return double.tryParse(value.toString()) ?? 0;
    }

    DateTime? asDateTime(dynamic value) {
      final text = value?.toString();
      if (text == null || text.trim().isEmpty) return null;
      return DateTime.tryParse(text.trim());
    }

    String asText(dynamic value, [String fallback = '']) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return fallback;
      return text;
    }

    bool asBool(dynamic value) {
      if (value is bool) return value;
      return value?.toString().toLowerCase() == 'true';
    }

    return ReservationPaymentReviewDto(
      reservationId: asText(json['reservationId']),
      lessonId: asText(json['lessonId']),
      reservationStatus: asText(json['reservationStatus'], 'pending'),
      lessonTitle: asText(json['lessonTitle'], 'Explicação'),
      subject: asText(json['subject'], 'Explicação'),
      tutoringTypeName: asText(json['tutoringTypeName']),
      teacherName: asText(json['teacherName'], 'Professor'),
      startTime: asDateTime(json['startTime']),
      endTime: asDateTime(json['endTime']),
      amount: asDouble(json['amount']),
      availableCredits: asDouble(json['availableCredits']),
      currency: asText(json['currency'], 'EUR'),
      canAfford: asBool(json['canAfford']),
      alreadyPaid: asBool(json['alreadyPaid']),
      reservationPaymentId: json['reservationPaymentId']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      platformFeeAmount: asDouble(json['platformFeeAmount']),
      teacherNetAmount: asDouble(json['teacherNetAmount']),
    );
  }
}
