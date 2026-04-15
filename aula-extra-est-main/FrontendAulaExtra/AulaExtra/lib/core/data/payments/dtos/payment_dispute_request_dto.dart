class PaymentDisputeRequestDto {
  const PaymentDisputeRequestDto({
    required this.paymentRecordId,
    required this.paymentSource,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
  });

  final String paymentRecordId;
  final String paymentSource;
  final String name;
  final String email;
  final String subject;
  final String message;

  Map<String, dynamic> toJson() {
    return {
      'paymentRecordId': paymentRecordId,
      'paymentSource': paymentSource,
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
    };
  }
}