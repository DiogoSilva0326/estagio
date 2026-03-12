class UserProfileDto {
  const UserProfileDto({
    this.id,
    this.email,
    this.username,
    this.displayName,
    this.educationLevel,
    this.mobileNumber,
    this.phoneNumber,
    this.biography,
  });

  final String? id;
  final String? email;
  final String? username;
  final String? displayName;
  final String? educationLevel;
  final String? mobileNumber;
  final String? phoneNumber;
  final String? biography;

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic v) => v is String ? v : null;

    return UserProfileDto(
      id: asString(json['id']) ?? asString(json['idUser']) ?? asString(json['id_user']),
      email: asString(json['email']),
      username: asString(json['username']),
      displayName: asString(json['displayName']),
      educationLevel: asString(json['educationLevel']),
      mobileNumber: asString(json['mobileNumber']),
      phoneNumber: asString(json['phoneNumber']),
      biography: asString(json['biography']),
    );
  }
}
