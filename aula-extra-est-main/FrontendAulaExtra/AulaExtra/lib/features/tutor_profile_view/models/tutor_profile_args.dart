class TutorProfileArgs {
  const TutorProfileArgs({
    required this.professorId,
    required this.name,
    required this.country,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.lessonsText,
    required this.pricePerHour,
    required this.tags,
  });

  final String professorId;
  final String name;
  final String country;
  final double rating;
  final int reviewCount;
  final String description;
  final String lessonsText;
  final int pricePerHour;
  final List<String> tags;
}
