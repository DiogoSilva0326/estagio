import 'dart:convert';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/tutors/dtos/my_tutor_dto.dart';
import 'package:http/http.dart' as http;

class MyTutorsApi {
  Future<List<MyTutorDto>> getMyTutors({required String token, String? areaId, String? role}) async {
    final queryParams = <String>[];
    if (areaId != null && areaId.trim().isNotEmpty) {
      queryParams.add('areaId=${Uri.encodeQueryComponent(areaId.trim())}');
    }
    if (role != null && role.trim().isNotEmpty) {
      queryParams.add('role=${Uri.encodeQueryComponent(role.trim())}');
    }

    final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final uri = ApiConfig.uri('/api/Users/me/tutors$queryString');

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) throw const MyTutorsException('Sessão expirada');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw MyTutorsException('Falha ao carregar profissionais (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! List) throw const MyTutorsException('Resposta inválida do servidor');

    return obj.whereType<Map<String, dynamic>>().map(MyTutorDto.fromJson).toList(growable: false);
  }
}

class MyTutorsException implements Exception {
  const MyTutorsException(this.message);
  final String message;
  @override
  String toString() => message;
}