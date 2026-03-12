import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/tutors/dtos/my_tutor_dto.dart';
import 'package:aula_extra/core/data/tutors/my_tutors_api.dart';

class MyTutorsService {
  MyTutorsService({
    MyTutorsApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? MyTutorsApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final MyTutorsApi _api;
  final TokenStorage _tokenStorage;

  Future<List<MyTutorDto>> getMyTutors() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const MyTutorsException('Sessão expirada');
    }

    return _api.getMyTutors(token: token);
  }
}
