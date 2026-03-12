class AuthUserDto {
  const AuthUserDto({
    this.id,
    this.email,
    this.username,
    this.displayName,
    this.firstName,
    this.lastName,
    this.educationLevel,
    this.mobileNumber,
    this.nif,
  });

  final String? id;
  final String? email;
  final String? username;
  final String? displayName;
  final String? firstName;
  final String? lastName;
  final String? educationLevel;
  final String? mobileNumber;
  final String? nif;

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    String? asString(dynamic v) => v is String ? v : null;

    return AuthUserDto(
      id: asString(json['id']),
      email: asString(json['email']),
      username: asString(json['username']),
      displayName: asString(json['displayName']) ?? asString(json['name']),
      firstName: asString(json['firstName']),
      lastName: asString(json['lastName']),
      educationLevel: asString(json['educationLevel']),
      mobileNumber: asString(json['mobileNumber']) ?? asString(json['phoneNumber']),
      nif: asString(json['nif']),
    );
  }
}
