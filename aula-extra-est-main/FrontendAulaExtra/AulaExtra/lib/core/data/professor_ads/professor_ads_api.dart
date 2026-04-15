import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ads_form_data_dto.dart';
import 'package:http/http.dart' as http;

class ProfessorAdsApi {
  Future<ProfessorAdsFormDataDto> getMyData({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/ProfessorAds/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorAdsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorAdsException(
        _extractErrorMessage(
          res.body,
          'Falha ao carregar dados do anúncio (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const ProfessorAdsException('Resposta inválida do servidor');
    }

    return ProfessorAdsFormDataDto.fromJson(obj);
  }

  Future<ProfessorAdDto> upsertMyAd({
    required String token,
    required String idDisciplina,
    required String idTutoringType,
    required double sessionPrice,
    String? description,
    String? photoUrl,
  }) async {
    final payload = <String, dynamic>{
      'idDisciplina': idDisciplina,
      'idTutoringType': idTutoringType,
      'sessionPrice': sessionPrice,
      'description': description?.trim().isEmpty == true
          ? null
          : description?.trim(),
      'photoUrl': photoUrl?.trim().isEmpty == true ? null : photoUrl?.trim(),
      'status': 'published',
    };

    final res = await http.post(
      ApiConfig.uri('/api/ProfessorAds/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode == 401) {
      throw const ProfessorAdsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorAdsException(
        _extractErrorMessage(
          res.body,
          'Falha ao guardar anúncio (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const ProfessorAdsException('Resposta inválida do servidor');
    }

    return ProfessorAdDto.fromJson(obj);
  }

  Future<ProfessorAdDto> updateMyAdStatus({
    required String token,
    required String idProfessorAd,
    required String status,
  }) async {
    final res = await http.patch(
      ApiConfig.uri('/api/ProfessorAds/me/$idProfessorAd/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'status': status}),
    );

    if (res.statusCode == 401) {
      throw const ProfessorAdsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorAdsException(
        _extractErrorMessage(
          res.body,
          'Falha ao atualizar anúncio (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const ProfessorAdsException('Resposta inválida do servidor');
    }

    return ProfessorAdDto.fromJson(obj);
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
        final error = decoded['error'];
        if (error is String && error.trim().isNotEmpty) {
          return error.trim();
        }
      }
    } catch (_) {
      // fallback below
    }

    return fallback;
  }
}

class ProfessorAdsException implements Exception {
  const ProfessorAdsException(this.message);

  final String message;

  @override
  String toString() => message;
}
