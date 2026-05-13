import 'dart:convert';

import 'package:aula_extra/core/data/auth/dtos/auth_response_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/public_professor_profile_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/global_professor_rating_summary_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_aluno_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_certificate_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_evaluations_overview_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_language_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_profile_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_stats_dto.dart';
import 'package:http/http.dart' as http;

class UpsertProfessorCertificateInput {
  UpsertProfessorCertificateInput({
    required this.name,
    this.description,
    required this.fileUrl,
  });

  final String name;
  final String? description;
  final String fileUrl;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'fileUrl': fileUrl,
  };
}

class UpsertProfessorLanguageInput {
  UpsertProfessorLanguageInput({
    required this.idLanguage,
    this.proficiencyLevel,
  });

  final String idLanguage;
  final String? proficiencyLevel;

  Map<String, dynamic> toJson() => {
    'idLanguage': idLanguage,
    'proficiencyLevel': proficiencyLevel,
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
      'currentSchool': currentSchool?.trim().isEmpty ?? true
          ? null
          : currentSchool?.trim(),
      'yearsExperience': yearsExperience,
      'presentationVideoUrl': presentationVideoUrl?.trim().isEmpty ?? true
          ? null
          : presentationVideoUrl?.trim(),
      'photo': photo?.trim().isEmpty ?? true ? null : photo?.trim(),
      'biography': biography?.trim().isEmpty ?? true ? null : biography?.trim(),
      'vat': vat?.trim().isEmpty ?? true ? null : vat?.trim(),
      'iban': iban?.trim().isEmpty ?? true ? null : iban?.trim(),
      'ibanDocumentUrl': ibanDocumentUrl?.trim().isEmpty ?? true
          ? null
          : ibanDocumentUrl?.trim(),
    };

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
      throw ProfessorsException(
        'Falha ao submeter candidatura (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthResponseDto.fromJson(obj);
  }

  Future<ProfessorProfileDto?> getMe({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Professors/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      return null;
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        'Falha ao carregar perfil do professor (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return ProfessorProfileDto.fromJson(obj);
  }

  Future<PublicProfessorProfileDto> getPublicProfessorProfile({
    required String idProfessor,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Professors/professors/$idProfessor/public-profile'),
      headers: const {'Content-Type': 'application/json'},
    );

    if (res.statusCode == 404) {
      throw const ProfessorsException('Perfil do professor não encontrado');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        _extractErrorMessage(
          res.body,
          'Falha ao carregar perfil público do professor (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return PublicProfessorProfileDto.fromJson(obj);
  }

  Future<ProfessorStatsDto> getMyStats({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Professors/me/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      // Backends without this route: assume no stats yet.
      return const ProfessorStatsDto(
        lessonsCount: 0,
        avgRating: 0,
        reviewCount: 0,
      );
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        'Falha ao carregar estatísticas (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return ProfessorStatsDto.fromJson(obj);
  }

  Future<GlobalProfessorRatingSummaryDto> getGlobalRatingSummary() async {
    final res = await http.get(
      ApiConfig.uri('/api/Professors/ratings/summary'),
      headers: const {'Content-Type': 'application/json'},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        'Falha ao carregar média global das avaliações (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return GlobalProfessorRatingSummaryDto.fromJson(obj);
  }

  Future<ProfessorEvaluationsOverviewDto> getMyEvaluations({
    required String token,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Professors/me/evaluations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      throw const ProfessorsException('Perfil do professor não encontrado');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        _extractErrorMessage(
          res.body,
          'Falha ao carregar avaliações do professor (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return ProfessorEvaluationsOverviewDto.fromJson(obj);
  }

  Future<List<ProfessorAlunoDto>> getMeusAlunos({required String token, String? role}) async {
    final query = role != null && role.isNotEmpty ? '?role=${Uri.encodeComponent(role)}' : '';
    
    final res = await http.get(
      ApiConfig.uri('/api/Professors/me/students$query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException('Falha ao carregar alunos (${res.statusCode})');
    }

    final body = jsonDecode(res.body);
    if (body is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return body
        .whereType<Map<String, dynamic>>()
        .map(ProfessorAlunoDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> getMyDisciplinas({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Professors/me/disciplinas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      // If the professor profile doesn't exist yet (or older backend without this route),
      // treat it as no selected disciplines.
      return const [];
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        'Falha ao carregar disciplinas (${res.statusCode})',
      );
    }

    final body = jsonDecode(res.body);
    if (body is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return body
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> setMyDisciplinas({
    required String token,
    required List<String> ids,
  }) async {
    final payload = <String, dynamic>{
      'ids': ids.where((e) => e.trim().isNotEmpty).toList(growable: false),
    };

    final res = await http.put(
      ApiConfig.uri('/api/Professors/me/disciplinas'),
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
      throw ProfessorsException(
        'Falha ao guardar disciplinas (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    final raw = (obj is Map<String, dynamic>) ? obj['disciplinas'] : obj;
    if (raw is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> createMyDisciplina({
    required String token,
    String? idDisciplina,
    required String idArea,
    String? idCicloEstudo,
    required String nome,
    String? descricao,
  }) async {
    final payload = <String, dynamic>{
      if (idDisciplina != null && idDisciplina.trim().isNotEmpty)
        'idDisciplina': idDisciplina,
      'idArea': idArea,
      'idCicloEstudo': idCicloEstudo,
      'nome': nome.trim(),
      'descricao': descricao?.trim(),
      'isActive': true,
    };

    final res = await http.post(
      ApiConfig.uri('/api/Professors/me/disciplinas'),
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
      throw ProfessorsException(
        'Falha ao criar disciplina (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    final raw = (obj is Map<String, dynamic>) ? obj['disciplinas'] : obj;
    if (raw is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> updateMyDisciplina({
    required String token,
    required String currentIdDisciplina,
    String? idDisciplina,
    required String idArea,
    String? idCicloEstudo,
    required String nome,
    String? descricao,
  }) async {
    final payload = <String, dynamic>{
      if (idDisciplina != null && idDisciplina.trim().isNotEmpty)
        'idDisciplina': idDisciplina,
      'idArea': idArea,
      'idCicloEstudo': idCicloEstudo,
      'nome': nome.trim(),
      'descricao': descricao?.trim(),
      'isActive': true,
    };

    final res = await http.put(
      ApiConfig.uri('/api/Professors/me/disciplinas/$currentIdDisciplina'),
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
      throw ProfessorsException(
        'Falha ao atualizar disciplina (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    final raw = (obj is Map<String, dynamic>) ? obj['disciplinas'] : obj;
    if (raw is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> removeMyDisciplina({
    required String token,
    required String idDisciplina,
  }) async {
    final res = await http.delete(
      ApiConfig.uri('/api/Professors/me/disciplinas/$idDisciplina'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        'Falha ao remover disciplina (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    final raw = (obj is Map<String, dynamic>) ? obj['disciplinas'] : obj;
    if (raw is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<ProfessorLanguageDto>> getLanguagesCatalog({
    required String token,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Professors/languages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        'Falha ao carregar idiomas (${res.statusCode})',
      );
    }

    final body = jsonDecode(res.body);
    if (body is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return body
        .whereType<Map<String, dynamic>>()
        .map(ProfessorLanguageDto.fromJson)
        .toList(growable: false);
  }

  Future<List<ProfessorLanguageDto>> getMyLanguages({
    required String token,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Professors/me/languages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      return const [];
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        'Falha ao carregar idiomas do professor (${res.statusCode})',
      );
    }

    final body = jsonDecode(res.body);
    if (body is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return body
        .whereType<Map<String, dynamic>>()
        .map(ProfessorLanguageDto.fromJson)
        .toList(growable: false);
  }

  Future<List<ProfessorLanguageDto>> setMyLanguages({
    required String token,
    required List<UpsertProfessorLanguageInput> items,
  }) async {
    final payload = <String, dynamic>{
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };

    final res = await http.put(
      ApiConfig.uri('/api/Professors/me/languages'),
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
      throw ProfessorsException('Falha ao guardar idiomas (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    final raw = (obj is Map<String, dynamic>) ? obj['languages'] : obj;
    if (raw is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return raw
        .whereType<Map<String, dynamic>>()
        .map(ProfessorLanguageDto.fromJson)
        .toList(growable: false);
  }

  Future<List<ProfessorCertificateDto>> getMyCertificates({
    required String token,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Professors/me/certificates'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      return const [];
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        _extractErrorMessage(
          res.body,
          'Falha ao carregar documentos (${res.statusCode})',
        ),
      );
    }

    final body = jsonDecode(res.body);
    if (body is! List) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return body
        .whereType<Map<String, dynamic>>()
        .map(ProfessorCertificateDto.fromJson)
        .toList(growable: false);
  }

  Future<ProfessorCertificateDto> createMyCertificate({
    required String token,
    required String name,
    String? description,
    required List<int> bytes,
    required String fileName,
  }) async {
    return _sendCertificateMultipart(
      token: token,
      method: 'POST',
      path: '/api/Professors/me/certificates',
      name: name,
      description: description,
      bytes: bytes,
      fileName: fileName,
    );
  }

  Future<ProfessorCertificateDto> updateMyCertificate({
    required String token,
    required String idCertificate,
    required String name,
    String? description,
    String? fileUrl,
    List<int>? bytes,
    String? fileName,
  }) async {
    return _sendCertificateMultipart(
      token: token,
      method: 'PUT',
      path: '/api/Professors/me/certificates/$idCertificate',
      name: name,
      description: description,
      fileUrl: fileUrl,
      bytes: bytes,
      fileName: fileName,
    );
  }

  Future<void> deleteMyCertificate({
    required String token,
    required String idCertificate,
  }) async {
    final res = await http.delete(
      ApiConfig.uri('/api/Professors/me/certificates/$idCertificate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        _extractErrorMessage(
          res.body,
          'Falha ao remover documento (${res.statusCode})',
        ),
      );
    }
  }

  Future<ProfessorCertificateDto> _sendCertificateMultipart({
    required String token,
    required String method,
    required String path,
    required String name,
    String? description,
    String? fileUrl,
    List<int>? bytes,
    String? fileName,
  }) async {
    final request = http.MultipartRequest(method, ApiConfig.uri(path));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name.trim();

    final normalizedDescription = description?.trim();
    if (normalizedDescription != null && normalizedDescription.isNotEmpty) {
      request.fields['description'] = normalizedDescription;
    }

    final normalizedFileUrl = fileUrl?.trim();
    if (normalizedFileUrl != null && normalizedFileUrl.isNotEmpty) {
      request.fields['fileUrl'] = normalizedFileUrl;
    }

    if (bytes != null) {
      final normalizedFileName = fileName?.trim() ?? '';
      if (normalizedFileName.isEmpty) {
        throw const ProfessorsException(
          'Nome do ficheiro em falta para o documento.',
        );
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: normalizedFileName,
        ),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 401) {
      throw const ProfessorsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ProfessorsException(
        _extractErrorMessage(
          res.body,
          'Falha ao guardar documento (${res.statusCode})',
        ),
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const ProfessorsException('Resposta inválida do servidor');
    }

    return ProfessorCertificateDto.fromJson(obj);
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
    } catch (_) {}

    return fallback;
  }
}

class ProfessorsException implements Exception {
  const ProfessorsException(this.message);
  final String message;

  @override
  String toString() => message;
}
