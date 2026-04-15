import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/tutoring_type_option_dto.dart';

class ProfessorAdsFormDataDto {
  const ProfessorAdsFormDataDto({
    required this.profilePhotoUrl,
    required this.disciplinas,
    required this.tutoringTypes,
    required this.ads,
  });

  final String? profilePhotoUrl;
  final List<DisciplinaDto> disciplinas;
  final List<TutoringTypeOptionDto> tutoringTypes;
  final List<ProfessorAdDto> ads;

  factory ProfessorAdsFormDataDto.fromJson(Map<String, dynamic> json) {
    final rawDisciplinas = json['disciplinas'];
    final rawTutoringTypes = json['tutoringTypes'] ?? json['tutoring_types'];
    final rawAds = json['ads'];

    return ProfessorAdsFormDataDto(
      profilePhotoUrl: (json['profilePhotoUrl'] ?? json['profile_photo_url'])
          ?.toString(),
      disciplinas: rawDisciplinas is List
          ? rawDisciplinas
                .whereType<Map<String, dynamic>>()
                .map(DisciplinaDto.fromJson)
                .toList(growable: false)
          : const <DisciplinaDto>[],
      tutoringTypes: rawTutoringTypes is List
          ? rawTutoringTypes
                .whereType<Map<String, dynamic>>()
                .map(TutoringTypeOptionDto.fromJson)
                .toList(growable: false)
          : const <TutoringTypeOptionDto>[],
      ads: rawAds is List
          ? rawAds
                .whereType<Map<String, dynamic>>()
                .map(ProfessorAdDto.fromJson)
                .toList(growable: false)
          : const <ProfessorAdDto>[],
    );
  }
}
