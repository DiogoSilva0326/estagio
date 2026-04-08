import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_certificate_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_language_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_stats_dto.dart';

class PublicProfessorProfileDto {
  const PublicProfessorProfileDto({
    required this.idProfessor,
    required this.idUser,
    required this.displayName,
    required this.username,
    this.photo,
    this.biography,
    this.presentationVideoUrl,
    this.currentSchool,
    this.yearsExperience,
    this.website,
    this.memberSince,
    required this.isVerified,
    required this.stats,
    required this.availability,
    required this.disciplinas,
    required this.languages,
    required this.certificates,
    required this.reviews,
  });

  final String idProfessor;
  final String idUser;
  final String displayName;
  final String username;
  final String? photo;
  final String? biography;
  final String? presentationVideoUrl;
  final String? currentSchool;
  final int? yearsExperience;
  final String? website;
  final DateTime? memberSince;
  final bool isVerified;
  final ProfessorStatsDto stats;
  final List<PublicProfessorAvailabilityDto> availability;
  final List<DisciplinaDto> disciplinas;
  final List<ProfessorLanguageDto> languages;
  final List<ProfessorCertificateDto> certificates;
  final List<PublicProfessorReviewDto> reviews;

  factory PublicProfessorProfileDto.fromJson(Map<String, dynamic> json) {
    String? asNullableString(dynamic value) {
      final normalized = value?.toString().trim();
      if (normalized == null || normalized.isEmpty) return null;
      return normalized;
    }

    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse('${value ?? ''}');
    }

    bool asBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
      return false;
    }

    DateTime? asDateTime(dynamic value) {
      final raw = asNullableString(value);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    }

    final rawStats = json['stats'];
    final rawAvailability = json['availability'];
    final stats = rawStats is Map<String, dynamic>
        ? ProfessorStatsDto.fromJson(rawStats)
        : const ProfessorStatsDto(
            lessonsCount: 0,
            avgRating: 0,
            reviewCount: 0,
          );

    final rawDisciplinas = json['disciplinas'];
    final rawLanguages = json['languages'];
    final rawCertificates = json['certificates'];
    final rawReviews = json['reviews'];

    return PublicProfessorProfileDto(
      idProfessor: asNullableString(json['idProfessor']) ?? '',
      idUser: asNullableString(json['idUser']) ?? '',
      displayName: asNullableString(json['displayName']) ?? 'Professor',
      username: asNullableString(json['username']) ?? '',
      photo: asNullableString(json['photo']),
      biography: asNullableString(json['biography']),
      presentationVideoUrl: asNullableString(json['presentationVideoUrl']),
      currentSchool: asNullableString(json['currentSchool']),
      yearsExperience: asInt(json['yearsExperience']),
      website: asNullableString(json['website']),
      memberSince: asDateTime(json['memberSince']),
      isVerified: asBool(json['isVerified']),
      stats: stats,
      availability: rawAvailability is List
          ? rawAvailability
                .whereType<Map<String, dynamic>>()
                .map(PublicProfessorAvailabilityDto.fromJson)
                .toList(growable: false)
          : const <PublicProfessorAvailabilityDto>[],
      disciplinas: rawDisciplinas is List
          ? rawDisciplinas
                .whereType<Map<String, dynamic>>()
                .map(DisciplinaDto.fromJson)
                .toList(growable: false)
          : const <DisciplinaDto>[],
      languages: rawLanguages is List
          ? rawLanguages
                .whereType<Map<String, dynamic>>()
                .map(ProfessorLanguageDto.fromJson)
                .toList(growable: false)
          : const <ProfessorLanguageDto>[],
      certificates: rawCertificates is List
          ? rawCertificates
                .whereType<Map<String, dynamic>>()
                .map(ProfessorCertificateDto.fromJson)
                .toList(growable: false)
          : const <ProfessorCertificateDto>[],
      reviews: rawReviews is List
          ? rawReviews
                .whereType<Map<String, dynamic>>()
                .map(PublicProfessorReviewDto.fromJson)
                .toList(growable: false)
          : const <PublicProfessorReviewDto>[],
    );
  }
}

class PublicProfessorAvailabilityDto {
  const PublicProfessorAvailabilityDto({
    required this.idScheduleBlock,
    required this.dayIndex,
    this.startTime,
    this.endTime,
    required this.isAvailable,
    this.defaultDurationMinutes,
    this.recurrenceRule,
  });

  final String idScheduleBlock;
  final int dayIndex;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isAvailable;
  final int? defaultDurationMinutes;
  final String? recurrenceRule;

  factory PublicProfessorAvailabilityDto.fromJson(Map<String, dynamic> json) {
    String? asNullableString(dynamic value) {
      final normalized = value?.toString().trim();
      if (normalized == null || normalized.isEmpty) return null;
      return normalized;
    }

    int? asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse('${value ?? ''}');
    }

    bool asBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final normalized = value?.toString().trim().toLowerCase();
      return normalized == 'true';
    }

    DateTime? asDateTime(dynamic value) {
      final raw = asNullableString(value);
      if (raw == null) return null;
      return DateTime.tryParse(raw)?.toLocal();
    }

    return PublicProfessorAvailabilityDto(
      idScheduleBlock: asNullableString(json['idScheduleBlock']) ?? '',
      dayIndex: asInt(json['dayIndex']) ?? -1,
      startTime: asDateTime(json['startTime']),
      endTime: asDateTime(json['endTime']),
      isAvailable: asBool(json['isAvailable']),
      defaultDurationMinutes: asInt(json['defaultDurationMinutes']),
      recurrenceRule: asNullableString(json['recurrenceRule']),
    );
  }
}

class PublicProfessorReviewDto {
  const PublicProfessorReviewDto({
    required this.idProfessorFeedback,
    required this.idUser,
    required this.reviewerName,
    this.reviewerImageUrl,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  final String idProfessorFeedback;
  final String idUser;
  final String reviewerName;
  final String? reviewerImageUrl;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  factory PublicProfessorReviewDto.fromJson(Map<String, dynamic> json) {
    String? asNullableString(dynamic value) {
      final normalized = value?.toString().trim();
      if (normalized == null || normalized.isEmpty) return null;
      return normalized;
    }

    int asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse('${value ?? ''}') ?? 0;
    }

    DateTime? asDateTime(dynamic value) {
      final raw = asNullableString(value);
      if (raw == null) return null;
      return DateTime.tryParse(raw);
    }

    return PublicProfessorReviewDto(
      idProfessorFeedback: asNullableString(json['idProfessorFeedback']) ?? '',
      idUser: asNullableString(json['idUser']) ?? '',
      reviewerName: asNullableString(json['reviewerName']) ?? 'Aluno',
      reviewerImageUrl: asNullableString(json['reviewerImageUrl']),
      rating: asInt(json['rating']).clamp(0, 5),
      comment: asNullableString(json['comment']),
      createdAt: asDateTime(json['createdAt']),
    );
  }
}
