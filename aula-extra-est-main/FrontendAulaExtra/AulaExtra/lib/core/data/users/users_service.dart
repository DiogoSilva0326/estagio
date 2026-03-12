import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/users/dtos/user_profile_dto.dart';
import 'package:aula_extra/core/data/users/users_api.dart';

class UsersService {
  UsersService({
    UsersApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? UsersApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final UsersApi _api;
  final TokenStorage _tokenStorage;

  Future<UserProfileDto> getMe() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const UsersException('Sessão expirada');
    }
    return _api.getMe(token: token);
  }

  Future<UserProfileDto> updateMe({
    required String displayName,
    required String educationLevel,
    required String biography,
    required String mobileNumber,
    required String phoneNumber,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const UsersException('Sessão expirada');
    }

    return _api.updateMe(
      token: token,
      displayName: displayName,
      educationLevel: educationLevel,
      biography: biography,
      mobileNumber: mobileNumber,
      phoneNumber: phoneNumber,
    );
  }
}
