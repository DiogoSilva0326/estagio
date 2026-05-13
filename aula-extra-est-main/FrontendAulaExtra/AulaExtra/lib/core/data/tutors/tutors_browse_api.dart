import 'dart:convert';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/tutors/dtos/tutor_browse_response_dto.dart';
import 'package:http/http.dart' as http;

class TutorsBrowseApi {
  Future<TutorBrowseResponseDto> browse({
    String? token,
    String? q,
    String? areaId,
    String? disciplinaId,
    String? cicloId,
    String? anoId,
    double? maxPrice,
    double? minRating,
    List<String>? availability,
    String? roleCategory,
    int page = 1,
    int pageSize = 4,
  }) async {
    final qp = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    };

    final trimmedQ = q?.trim();
    if (trimmedQ != null && trimmedQ.isNotEmpty) qp['q'] = trimmedQ;
    if (areaId != null && areaId.trim().isNotEmpty) qp['areaId'] = areaId.trim();
    if (disciplinaId != null && disciplinaId.trim().isNotEmpty) qp['disciplinaId'] = disciplinaId.trim();
    if (cicloId != null && cicloId.trim().isNotEmpty) qp['cicloId'] = cicloId.trim();
    if (anoId != null && anoId.trim().isNotEmpty) qp['anoId'] = anoId.trim();
    if (maxPrice != null && maxPrice > 0) qp['maxPrice'] = maxPrice.toStringAsFixed(2);
    if (minRating != null && minRating > 0) qp['minRating'] = minRating.toStringAsFixed(1);
    
    if (roleCategory != null && roleCategory.trim().isNotEmpty) {
      qp['category'] = roleCategory.trim(); 
    }

    if (availability != null && availability.isNotEmpty) {
      final normalized = availability
          .map((a) => a.trim())
          .where((a) => a.isNotEmpty)
          .toList(growable: false);
      if (normalized.isNotEmpty) qp['availability'] = normalized.join(',');
    }

    final uri = ApiConfig.uri('/api/Professors/browse').replace(queryParameters: qp);

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    final t = token?.trim();
    if (t != null && t.isNotEmpty) headers['Authorization'] = 'Bearer $t';

    final res = await http.get(uri, headers: headers);

    if (res.statusCode == 401) {
      throw const TutorsBrowseException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw TutorsBrowseException('Falha ao carregar explicadores (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const TutorsBrowseException('Resposta inválida do servidor');
    }

    return TutorBrowseResponseDto.fromJson(obj);
  }
}

class TutorsBrowseException implements Exception {
  const TutorsBrowseException(this.message);
  final String message;
  @override
  String toString() => message;
}