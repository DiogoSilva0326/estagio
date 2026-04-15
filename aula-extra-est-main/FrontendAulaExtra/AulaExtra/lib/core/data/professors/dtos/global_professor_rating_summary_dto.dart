class GlobalProfessorRatingSummaryDto {
  const GlobalProfessorRatingSummaryDto({
    required this.avgRating,
    required this.reviewCount,
  });

  final double avgRating;
  final int reviewCount;

  factory GlobalProfessorRatingSummaryDto.fromJson(Map<String, dynamic> json) {
    double asDouble(Object? value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    int asInt(Object? value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return GlobalProfessorRatingSummaryDto(
      avgRating: asDouble(
        json['avgRating'] ?? json['AvgRating'] ?? json['avg_rating'],
      ),
      reviewCount: asInt(
        json['reviewCount'] ?? json['ReviewCount'] ?? json['review_count'],
      ),
    );
  }
}
