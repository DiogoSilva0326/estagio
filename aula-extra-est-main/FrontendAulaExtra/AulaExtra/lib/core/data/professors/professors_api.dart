import 'dart:convert';

import 'package:aula_extra/core/data/auth/dtos/auth_response_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:http/http.dart' as http;

class UpsertProfessorCertificateInput {
  UpsertProfessorCertificateInput({
    required this.name,
    required this.fileUrl,
  });

  final String name;
  final String fileUrl;

  Map<String, dynamic> toJson() => {
        'name': name,
        'fileUrl': fileUrl,
      };
}

class ProfessorsApi {
  Future<AuthResponseDto> upsertMe({
    required String token,
    required String username,
    required String mobileNumber,
    required String nif,
    String? currentSchool,
    int? yearsExperience,
    String? presentationVideoUrl,
    String? photo,
    String? biography,
    String? vat,
    String? iban,
    String? ibanDocumentUrl,
    List<UpsertProfessorCertificateInput>? certificates,
  }) async {
    final payload = <String, dynamic>{
      'username': username,
      'mobileNumber': mobileNumber,
      'nif': nif,
    };

    final cs = currentSchool?.trim();
    if (cs != null && cs.isNotEmpty) payload['currentSchool'] = cs;

    if (yearsExperience != null) payload['yearsExperience'] = yearsExperience;

    final pvu = presentationVideoUrl?.trim();
    if (pvu != null && pvu.isNotEmpty) payload['presentationVideoUrl'] = pvu;

    final p = photo?.trim();
    if (p != null && p.isNotEmpty) payload['photo'] = p;

    final b = biography?.trim();
    if (b != null && b.isNotEmpty) payload['biography'] = b;

    final v = vat?.trim();
    if (v != null && v.isNotEmpty) payload['vat'] = v;

    final i = iban?.trim();
    if (i != null && i.isNotEmpty) payload['iban'] = i;

    final idu = ibanDocumentUrl?.trim();
    if (idu != null && idu.isNotEmpty) payload['ibanDocumentUrl'] = idu;

    if (certificates != null && certificates.isNotEmpty) {
      payload['certificates'] = certificates.map((c) => c.toJson()).toList();
    }

    final res = await http.put(
      ApiConfig.uri('/api/Professors/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException('Falha ao submeter candidatura (${res.statusCode})');
    }

    final obj = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthResponseDto.fromJson(obj);
  }
}

class ProfessorsException implements Exception {
  const ProfessorsException(this.message);
  final String message;

  @override
  String toString() => message;
}
