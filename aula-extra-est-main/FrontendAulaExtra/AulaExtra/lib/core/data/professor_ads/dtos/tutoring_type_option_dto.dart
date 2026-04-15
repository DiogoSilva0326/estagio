class TutoringTypeOptionDto {
  const TutoringTypeOptionDto({
    required this.idTutoringType,
    required this.name,
    this.description,
  });

  final String idTutoringType;
  final String name;
  final String? description;

  factory TutoringTypeOptionDto.fromJson(Map<String, dynamic> json) {
    return TutoringTypeOptionDto(
      idTutoringType:
          (json['idTutoringType'] ??
                  json['IdTutoringType'] ??
                  json['id_tutoring_type'])
              ?.toString() ??
          '',
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      description: (json['description'] ?? json['Description'])?.toString(),
    );
  }
}
