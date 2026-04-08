class UserProfileDto {
  const UserProfileDto({
    this.id,
    this.email,
    this.username,
    this.displayName,
    this.educationLevel,
    this.mobileNumber,
    this.phoneNumber,
    this.website,
    this.nif,
    this.biography,
    this.creationDate,
    this.profileImageUrl,
    this.profileImageThumbnailUrl,
    this.profileImageCloudflareId,
    this.profileImageProvider,
    this.profileImageSource,
  });

  final String? id;
  final String? email;
  final String? username;
  final String? displayName;
  final String? educationLevel;
  final String? mobileNumber;
  final String? phoneNumber;
  final String? website;
  final String? nif;
  final String? biography;
  final DateTime? creationDate;
  final String? profileImageUrl;
  final String? profileImageThumbnailUrl;
  final String? profileImageCloudflareId;
  final String? profileImageProvider;
  final String? profileImageSource;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic v) => v is String ? v : null;
    DateTime? asDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    return UserProfileDto(
      id:
          asString(json['id']) ??
          asString(json['idUser']) ??
          asString(json['id_user']),
      email: asString(json['email']),
      username: asString(json['username']),
      displayName: asString(json['displayName']),
      educationLevel: asString(json['educationLevel']),
      mobileNumber: asString(json['mobileNumber']),
      phoneNumber: asString(json['phoneNumber']),
      website: asString(json['website']),
      nif: asString(json['nif']),
      biography: asString(json['biography']),
        creationDate:
          asDate(json['creationDate']) ??
          asDate(json['CreationDate']) ??
          asDate(json['creation_date']),
      profileImageUrl:
          asString(json['profileImageUrl']) ??
          asString(json['profile_image_url']),
      profileImageThumbnailUrl:
          asString(json['profileImageThumbnailUrl']) ??
          asString(json['profile_image_thumbnail_url']),
      profileImageCloudflareId:
          asString(json['profileImageCloudflareId']) ??
          asString(json['profile_image_cloudflare_id']),
      profileImageProvider:
          asString(json['profileImageProvider']) ??
          asString(json['profile_image_provider']),
      profileImageSource:
          asString(json['profileImageSource']) ??
          asString(json['profile_image_source']),
    );
  }
}
