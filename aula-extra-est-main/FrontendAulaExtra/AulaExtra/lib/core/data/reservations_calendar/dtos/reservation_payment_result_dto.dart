class ReservationPaymentResultDto {
  const ReservationPaymentResultDto({
    required this.reservationId,
    required this.lessonId,
    required this.amount,
    required this.platformFeeAmount,
    required this.teacherNetAmount,
    required this.currency,
    required this.studentBalanceAfter,
    required this.professorBalanceAfter,
    required this.alreadyPaid,
    this.reservationPaymentId,
  });

  final String reservationId;
  final String lessonId;
  final double amount;
  final double platformFeeAmount;
  final double teacherNetAmount;
  final String currency;
  final double studentBalanceAfter;
  final double professorBalanceAfter;
  final bool alreadyPaid;
  final String? reservationPaymentId;

  factory ReservationPaymentResultDto.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic value) {
      if (value == null) return 0;
      return double.tryParse(value.toString()) ?? 0;
    }

    bool asBool(dynamic value) {
      if (value is bool) return value;
      return value?.toString().toLowerCase() == 'true';
    }

    String asText(dynamic value, [String fallback = '']) {
      final text = value?.toString().trim();
      if (text == null || text.isEmpty) return fallback;
      return text;
    }

    return ReservationPaymentResultDto(
      reservationId: asText(json['reservationId']),
      lessonId: asText(json['lessonId']),
      amount: asDouble(json['amount']),
      platformFeeAmount: asDouble(json['platformFeeAmount']),
      teacherNetAmount: asDouble(json['teacherNetAmount']),
      currency: asText(json['currency'], 'EUR'),
      studentBalanceAfter: asDouble(json['studentBalanceAfter']),
      professorBalanceAfter: asDouble(json['professorBalanceAfter']),
      alreadyPaid: asBool(json['alreadyPaid']),
      reservationPaymentId: json['reservationPaymentId']?.toString(),
    );
  }
}
