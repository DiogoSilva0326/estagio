class StudentTopupSimulationRequestDto {
  const StudentTopupSimulationRequestDto({
    required this.creditsAmount,
    required this.paymentAmount,
    required this.packageName,
    required this.topupType,
  });

  final double creditsAmount;
  final double paymentAmount;
  final String packageName;
  final String topupType;

  Map<String, dynamic> toJson() {
    return {
      'creditsAmount': creditsAmount,
      'paymentAmount': paymentAmount,
      'packageName': packageName,
      'topupType': topupType,
    };
  }
}