import 'dart:convert';

import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/ciclo_estudo_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:http/http.dart' as http;

class EducationApi {
  Future<List<AreaDto>> getPublicAreas() async {
    final res = await http.get(
      ApiConfig.uri('/api/Education/areas'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException('Falha ao carregar áreas (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <AreaDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(AreaDto.fromJson)
        .where(
          (area) =>
              area.idArea.trim().isNotEmpty && area.nome.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> getPublicDisciplinasWithProfessors() async {
    final res = await http.get(
      ApiConfig.uri('/api/Education/disciplinas/public'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException(
        'Falha ao carregar disciplinas públicas (${res.statusCode})',
      );
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <DisciplinaDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .where(
          (disciplina) =>
              disciplina.idDisciplina.trim().isNotEmpty &&
              disciplina.nome.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<List<CicloEstudoDto>> getPublicCiclosEstudo() async {
    final res = await http.get(
      ApiConfig.uri('/api/Education/ciclos-estudo'),
      headers: {'Content-Type': 'application/json'},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException(
        'Falha ao carregar ciclos de estudo (${res.statusCode})',
      );
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <CicloEstudoDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(CicloEstudoDto.fromJson)
        .where(
          (c) => c.idCicloEstudo.trim().isNotEmpty && c.nome.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<List<CicloEstudoDto>> getCiclosEstudo({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Education/ciclos-estudo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const EducationException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException(
        'Falha ao carregar ciclos de estudo (${res.statusCode})',
      );
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <CicloEstudoDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(CicloEstudoDto.fromJson)
        .where(
          (c) => c.idCicloEstudo.trim().isNotEmpty && c.nome.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<List<AreaDto>> getAreas({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Education/areas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const EducationException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException('Falha ao carregar áreas (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <AreaDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(AreaDto.fromJson)
        .where(
          (area) =>
              area.idArea.trim().isNotEmpty && area.nome.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> getDisciplinasByArea({
    required String token,
    required String idArea,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Education/areas/$idArea/disciplinas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const EducationException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException(
        'Falha ao carregar disciplinas (${res.statusCode})',
      );
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <DisciplinaDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> getCatalog({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Education/disciplinas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const EducationException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException(
        'Falha ao carregar disciplinas (${res.statusCode})',
      );
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <DisciplinaDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> getMyDisciplinas({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Education/me/disciplinas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const EducationException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException(
        'Falha ao carregar as suas disciplinas (${res.statusCode})',
      );
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <DisciplinaDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> setMyDisciplinas({
    required String token,
    required List<String> ids,
  }) async {
    final res = await http.put(
      ApiConfig.uri('/api/Education/me/disciplinas'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'ids': ids}),
    );

    if (res.statusCode == 401) {
      throw const EducationException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException(
        'Falha ao guardar disciplinas (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) return <DisciplinaDto>[];

    final disciplinas = obj['disciplinas'];
    if (disciplinas is! List) return <DisciplinaDto>[];

    return disciplinas
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> removeMyDisciplina({
    required String token,
    required String idDisciplina,
  }) async {
    final res = await http.delete(
      ApiConfig.uri('/api/Education/me/disciplinas/$idDisciplina'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const EducationException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException(
        'Falha ao remover disciplina (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) return <DisciplinaDto>[];

    final disciplinas = obj['disciplinas'];
    if (disciplinas is! List) return <DisciplinaDto>[];

    return disciplinas
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }

  Future<List<DisciplinaDto>> removeMyArea({
    required String token,
    required String idArea,
  }) async {
    final res = await http.delete(
      ApiConfig.uri('/api/Education/me/areas/$idArea'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const EducationException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw EducationException('Falha ao remover área (${res.statusCode})');
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) return <DisciplinaDto>[];

    final disciplinas = obj['disciplinas'];
    if (disciplinas is! List) return <DisciplinaDto>[];

    return disciplinas
        .whereType<Map<String, dynamic>>()
        .map(DisciplinaDto.fromJson)
        .toList(growable: false);
  }
}

class EducationException implements Exception {
  const EducationException(this.message);
  final String message;

  @override
  String toString() => message;
}
