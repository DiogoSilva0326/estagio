import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/users/dtos/user_profile_dto.dart';
import 'package:aula_extra/core/data/users/users_api.dart';

class UsersService {
  UsersService({UsersApi? api, TokenStorage? tokenStorage})
    : _api = api ?? UsersApi(),
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
    required String username,
    required String displayName,
    required String educationLevel,
    required String biography,
    required String mobileNumber,
    required String phoneNumber,
    required String website,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const UsersException('Sessão expirada');
    }

    return _api.updateMe(
      token: token,
      username: username,
      displayName: displayName,
      educationLevel: educationLevel,
      biography: biography,
      mobileNumber: mobileNumber,
      phoneNumber: phoneNumber,
      website: website,
    );
  }

  Future<UserProfileDto> uploadMyProfileImage({
    required List<int> bytes,
    required String fileName,
  }) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const UsersException('Sessão expirada');
    }

    return _api.uploadMyProfileImage(
      token: token,
      bytes: bytes,
      fileName: fileName,
    );
  }

  Future<UserProfileDto> setMyProfileImageFromUrl(String imageUrl) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const UsersException('Sessão expirada');
    }

    return _api.setMyProfileImageFromUrl(token: token, imageUrl: imageUrl);
  }

  Future<void> deleteMyProfileImage() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const UsersException('Sessão expirada');
    }

    await _api.deleteMyProfileImage(token: token);
  }
}
