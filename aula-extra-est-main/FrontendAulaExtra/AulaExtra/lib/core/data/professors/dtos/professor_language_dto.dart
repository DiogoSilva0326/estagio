class ProfessorLanguageDto {
  const ProfessorLanguageDto({
    required this.idLanguage,
    required this.nome,
    this.proficiencyLevel,
  });

  final String idLanguage;
  final String nome;
  final String? proficiencyLevel;

  ProfessorLanguageDto copyWith({
    String? idLanguage,
    String? nome,
    String? proficiencyLevel,
  }) {
    return ProfessorLanguageDto(
      idLanguage: idLanguage ?? this.idLanguage,
      nome: nome ?? this.nome,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
    );
  }

  factory ProfessorLanguageDto.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic value) => value is String ? value : null;

    return ProfessorLanguageDto(
      idLanguage:
          asString(json['idLanguage']) ?? asString(json['id_language']) ?? '',
      nome: asString(json['nome']) ?? asString(json['name']) ?? '',
      proficiencyLevel:
          asString(json['proficiencyLevel']) ??
          asString(json['proficiency_level']),
    );
  }

  Map<String, dynamic> toJson() => {
    'idLanguage': idLanguage,
    'proficiencyLevel': proficiencyLevel,
  };
}
