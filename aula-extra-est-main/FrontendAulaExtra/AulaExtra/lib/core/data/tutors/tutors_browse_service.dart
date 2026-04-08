import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/tutors/dtos/tutor_browse_response_dto.dart';
import 'package:aula_extra/core/data/tutors/tutors_browse_api.dart';

class TutorsBrowseService {
  TutorsBrowseService({
    TutorsBrowseApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? TutorsBrowseApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final TutorsBrowseApi _api;
  final TokenStorage _tokenStorage;

  Future<TutorBrowseResponseDto> browse({
    String? q,
    String? areaId,
    String? disciplinaId,
    String? cicloId,
    String? anoId,
    double? maxPrice,
    double? minRating,
    List<String>? availability,
    int page = 1,
    int pageSize = 4,
  }) async {
    final token = await _tokenStorage.loadToken();
    return _api.browse(
      token: token,
      q: q,
      areaId: areaId,
      disciplinaId: disciplinaId,
      cicloId: cicloId,
      anoId: anoId,
      maxPrice: maxPrice,
      minRating: minRating,
      availability: availability,
      page: page,
      pageSize: pageSize,
    );
  }
}
