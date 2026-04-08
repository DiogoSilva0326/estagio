class ProfessorCertificateDto {
  const ProfessorCertificateDto({
    required this.idCertificate,
    required this.idProfessor,
    this.name,
    this.description,
    this.fileUrl,
    this.verified,
    this.verifiedByUserId,
    this.createdAt,
    this.updatedAt,
  });

  final String idCertificate;
  final String idProfessor;
  final String? name;
  final String? description;
  final String? fileUrl;
  final bool? verified;
  final String? verifiedByUserId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isVerified => verified ?? false;

  factory ProfessorCertificateDto.fromJson(Map<String, dynamic> json) {
    String? asNullableString(dynamic value) {
      final normalized = value?.toString().trim();
      if (normalized == null || normalized.isEmpty) return null;
      return normalized;
    }

    bool? asBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
      return null;
    }

    DateTime? asDateTime(dynamic value) {
      final raw = asNullableString(value);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    }

    return ProfessorCertificateDto(
      idCertificate:
          asNullableString(json['idCertificate']) ??
          asNullableString(json['IdCertificate']) ??
          asNullableString(json['id_certificate']) ??
          '',
      idProfessor:
          asNullableString(json['idProfessor']) ??
          asNullableString(json['IdProfessor']) ??
          asNullableString(json['id_professor']) ??
          '',
      name: asNullableString(json['name']) ?? asNullableString(json['Name']),
      description:
          asNullableString(json['description']) ??
          asNullableString(json['Description']),
      fileUrl:
          asNullableString(json['fileUrl']) ??
          asNullableString(json['FileUrl']) ??
          asNullableString(json['file_url']),
      verified: asBool(json['verified'] ?? json['Verified']),
      verifiedByUserId:
          asNullableString(json['verifiedByUserId']) ??
          asNullableString(json['VerifiedByUserId']) ??
          asNullableString(json['verified_by_user_id']),
      createdAt: asDateTime(
        json['createdAt'] ?? json['CreatedAt'] ?? json['created_at'],
      ),
      updatedAt: asDateTime(
        json['updatedAt'] ?? json['UpdatedAt'] ?? json['updated_at'],
      ),
    );
  }
}
