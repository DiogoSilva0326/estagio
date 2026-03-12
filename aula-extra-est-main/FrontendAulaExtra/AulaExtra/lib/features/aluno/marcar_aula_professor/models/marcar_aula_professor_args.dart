class MarcarAulaProfessorArgs {
  const MarcarAulaProfessorArgs({
    required this.tutorName,
    required this.subject,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.pricePerHour,
  });

  final String tutorName;
  final String subject;
  final double rating;
  final int reviewCount;
  final String location;
  final int pricePerHour;
}
