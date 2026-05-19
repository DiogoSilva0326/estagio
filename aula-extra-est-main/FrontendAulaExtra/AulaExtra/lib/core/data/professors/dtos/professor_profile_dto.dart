class ProfessorProfileDto {
  const ProfessorProfileDto({
    this.idProfessor,
    this.idUser,
    this.currentSchool,
    this.yearsExperience,
    this.photo,
    this.biography,
    this.presentationVideoUrl,
    this.vat,
    this.iban,
    this.ibanDocumentUrl,
    this.isVerifiedIban,
    this.isActive,
    this.isVerified,
    this.supportTypes = const <String>[],
  });

  final String? idProfessor;
  final String? idUser;
  final String? currentSchool;
  final int? yearsExperience;
  final String? photo;
  final String? biography;
  final String? presentationVideoUrl;
  final String? vat;
  final String? iban;
  final String? ibanDocumentUrl;
  final bool? isVerifiedIban;
  final bool? isActive;
  final bool? isVerified;
  final List<String> supportTypes;

  factory ProfessorProfileDto.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic value) => value is String ? value : null;
    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse('${value ?? ''}');
    }

    bool? asBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
      return null;
    }

    List<String> asStringList(dynamic value) {
      if (value is! List) return const <String>[];

      return value
          .whereType<Object>()
          .map((item) => item.toString().trim().toLowerCase())
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList(growable: false);
    }

    return ProfessorProfileDto(
      idProfessor:
          asString(json['idProfessor']) ?? asString(json['id_professor']),
      idUser: asString(json['idUser']) ?? asString(json['id_user']),
      currentSchool:
          asString(json['currentSchool']) ?? asString(json['current_school']),
      yearsExperience: asInt(
        json['yearsExperience'] ?? json['years_experience'],
      ),
      photo: asString(json['photo']),
      biography: asString(json['biography']),
      presentationVideoUrl:
          asString(json['presentationVideoUrl']) ??
          asString(json['presentation_video_url']),
      vat: asString(json['vat']),
      iban: asString(json['iban']),
      ibanDocumentUrl:
          asString(json['ibanDocumentUrl']) ??
          asString(json['iban_document_url']),
      isVerifiedIban: asBool(
        json['isVerifiedIban'] ?? json['is_verified_iban'],
      ),
      isActive: asBool(json['isActive'] ?? json['is_active']),
      isVerified: asBool(json['isVerified'] ?? json['is_verified']),
      supportTypes: asStringList(json['supportTypes'] ?? json['support_types']),
    );
  }
}
