import 'auth_user_dto.dart';

class AuthResponseDto {
  AuthResponseDto({
    required this.token,
    required this.roles,
    required this.user,
    this.message,
  });

  final String token;
  final List<String> roles;
  final AuthUserDto? user;
  final String? message;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    final token = (json['token'] as String?) ?? '';

    final rolesDynamic = json['roles'];
    final roles = (rolesDynamic is List)
        ? rolesDynamic.whereType<String>().toList(growable: false)
        : <String>[];

    final userJson = json['user'];
    final user = userJson is Map<String, dynamic> ? AuthUserDto.fromJson(userJson) : null;

    return AuthResponseDto(
      token: token,
      roles: roles,
      user: user,
      message: json['message'] as String?,
    );
  }
}
