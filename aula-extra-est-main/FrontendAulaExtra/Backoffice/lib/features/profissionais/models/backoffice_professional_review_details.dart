class BackofficeProfessionalReviewDetails {
  const BackofficeProfessionalReviewDetails({
    required this.idProfessor,
    required this.displayName,
    required this.email,
    required this.mobileNumber,
    required this.phoneNumber,
    required this.educationLevel,
    required this.website,
    required this.photoUrl,
    required this.biography,
    required this.presentationVideoUrl,
    required this.currentSchool,
    required this.yearsExperience,
    required this.memberSince,
    required this.isApproved,
    required this.isActive,
    required this.isVerified,
    required this.isVerifiedIban,
    required this.isRejected,
    required this.statusLabel,
    required this.lessonsCount,
    required this.averageRating,
    required this.reviewCount,
    required this.areaNames,
    required this.disciplinas,
    required this.languages,
    required this.certificates,
    required this.reviews,
    required this.ibanDocumentUrl,
    required this.psychologistProofDocumentUrl,
    required this.supportTypes,
  });

  final String idProfessor;
  final String displayName;
  final String email;
  final String? mobileNumber;
  final String? phoneNumber;
  final String? educationLevel;
  final String? website;
  final String? photoUrl;
  final String? biography;
  final String? presentationVideoUrl;
  final String? currentSchool;
  final int yearsExperience;
  final DateTime? memberSince;
  final bool isApproved;
  final bool isActive;
  final bool isVerified;
  final bool isVerifiedIban;
  final bool isRejected;
  final String statusLabel;
  final int lessonsCount;
  final double averageRating;
  final int reviewCount;
  final List<String> areaNames;
  final List<String> disciplinas;
  final List<String> languages;
  final List<BackofficeProfessionalCertificate> certificates;
  final List<BackofficeProfessionalReviewEntry> reviews;
  final String? ibanDocumentUrl;
  final String? psychologistProofDocumentUrl;
  final List<String> supportTypes;

  String get moderationLabel => isRejected ? 'REJEITADO' : isApproved ? 'APROVADO' : 'PENDENTE';
}

class BackofficeProfessionalCertificate {
  const BackofficeProfessionalCertificate({
    required this.idCertificate,
    required this.name,
    required this.description,
    required this.fileUrl,
    required this.approved,
    required this.verified,
    this.canReview = true,
  });

  final String idCertificate;
  final String name;
  final String? description;
  final String? fileUrl;
  final bool approved;
  final bool verified;
  final bool canReview;
}

class BackofficeProfessionalReviewEntry {
  const BackofficeProfessionalReviewEntry({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String reviewerName;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
}
