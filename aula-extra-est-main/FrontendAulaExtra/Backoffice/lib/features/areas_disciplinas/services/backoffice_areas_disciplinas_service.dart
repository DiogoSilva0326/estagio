import 'package:flutter/material.dart';

import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../models/area_disciplinas_item.dart';

class BackofficeAreasDisciplinasViewData {
  const BackofficeAreasDisciplinasViewData({
    required this.items,
    this.warningMessage,
  });

  final List<AreaDisciplinasItem> items;
  final String? warningMessage;
}

class BackofficeAreasDisciplinasService {
  BackofficeAreasDisciplinasService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  }) : _apiClient = apiClient ?? BackofficeApiClient(),
       _sessionController =
           sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  static const List<_AreaVisualStyle> _visualStyles = <_AreaVisualStyle>[
    _AreaVisualStyle(
      icon: Icons.calculate_rounded,
      iconBackgroundColor: Color(0x2641A7D7),
      iconColor: Color(0xFF41A7D7),
    ),
    _AreaVisualStyle(
      icon: Icons.biotech_outlined,
      iconBackgroundColor: Color(0x26FB7B02),
      iconColor: Color(0xFFFB7B02),
    ),
    _AreaVisualStyle(
      icon: Icons.menu_book_rounded,
      iconBackgroundColor: Color(0x80FFBDC0),
      iconColor: Color(0xFFF15C64),
    ),
    _AreaVisualStyle(
      icon: Icons.public_rounded,
      iconBackgroundColor: Color(0x2612B76A),
      iconColor: Color(0xFF12B76A),
    ),
  ];

  Future<BackofficeAreasDisciplinasViewData> fetch() async {
    await _sessionController.initialize();

    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      return const BackofficeAreasDisciplinasViewData(
        items: <AreaDisciplinasItem>[],
        warningMessage:
            'Sem sessão de administrador ativa. Inicie sessão para carregar áreas e disciplinas.',
      );
    }

    try {
      final areasPayload = await _apiClient.getListJson(
        ApiConfig.uri('/api/Education/areas'),
        token: token,
      );
      final disciplinasPayload = await _apiClient.getListJson(
        ApiConfig.uri('/api/Education/disciplinas'),
        token: token,
      );

      final disciplinasByArea = <String, List<AreaDisciplinaEntry>>{};
      for (final raw in disciplinasPayload.whereType<Map>()) {
        final disciplina = _mapDisciplina(raw.cast<String, dynamic>());
        final areaId = disciplina.idArea;
        if (areaId.isEmpty) {
          continue;
        }
        disciplinasByArea.putIfAbsent(areaId, () => <AreaDisciplinaEntry>[]).add(
          disciplina,
        );
      }

      final items = areasPayload
          .whereType<Map>()
          .map((raw) => raw.cast<String, dynamic>())
          .map(
            (json) => _mapArea(
              json,
              disciplinasByArea[_readString(json, const <String>['idArea', 'id_area'])] ??
                  const <AreaDisciplinaEntry>[],
            ),
          )
          .toList(growable: false);

      return BackofficeAreasDisciplinasViewData(items: items);
    } catch (_) {
      return const BackofficeAreasDisciplinasViewData(
        items: <AreaDisciplinasItem>[],
        warningMessage:
            'Nao foi possivel sincronizar areas e disciplinas com a API. Tente novamente.',
      );
    }
  }

  Future<void> createArea({
    required String areaName,
    required List<String> disciplinaNames,
    required String targetRole,
  }) async {
    final token = await _requireToken();
    final normalizedAreaName = areaName.trim();
    if (normalizedAreaName.isEmpty) {
      throw Exception('O nome da area e obrigatorio.');
    }

    final createdArea = await _apiClient.postJson(
      ApiConfig.uri('/api/Education/areas'),
      token: token,
      body: <String, dynamic>{
        'nome': normalizedAreaName,
        'descricao': null,
        'targetRole': targetRole,
      },
    );

    final areaId = _readString(createdArea, const <String>['idArea', 'id_area']);
    if (areaId.isEmpty) {
      throw Exception('A API nao devolveu o identificador da area criada.');
    }

    for (final disciplinaName in _normalizeNames(disciplinaNames)) {
      await _createDisciplina(
        areaId: areaId,
        disciplinaName: disciplinaName,
        token: token,
      );
    }
  }

  Future<void> updateAreaAndDisciplinas({
    required AreaDisciplinasItem area,
    required String areaName,
    required List<String> disciplinaNames,
    required String targetRole, 
  }) async {
    final token = await _requireToken();
    final normalizedAreaName = areaName.trim();
    if (normalizedAreaName.isEmpty) {
      throw Exception('O nome da area e obrigatorio.');
    }

    if (normalizedAreaName != area.nome.trim() || targetRole != area.targetRole) {
      await _apiClient.putJson(
        ApiConfig.uri('/api/Education/areas/${area.idArea}'),
        token: token,
        body: <String, dynamic>{
          'idArea': area.idArea,
          'nome': normalizedAreaName,
          'descricao': null,
          'targetRole': targetRole, 
        },
      );
    }

    final existingByKey = <String, AreaDisciplinaEntry>{
      for (final disciplina in area.disciplinas)
        _normalizeValue(disciplina.nome): disciplina,
    };
    final desiredNames = _normalizeNames(disciplinaNames);
    final desiredKeys = desiredNames.map(_normalizeValue).toSet();

    for (final disciplina in area.disciplinas) {
      if (!desiredKeys.contains(_normalizeValue(disciplina.nome))) {
        await _apiClient.deleteJson(
          ApiConfig.uri('/api/Education/disciplinas/${disciplina.idDisciplina}'),
          token: token,
        );
      }
    }

    for (final disciplinaName in desiredNames) {
      if (!existingByKey.containsKey(_normalizeValue(disciplinaName))) {
        await _createDisciplina(
          areaId: area.idArea,
          disciplinaName: disciplinaName,
          token: token,
        );
      }
    }
  }

  AreaDisciplinasItem _mapArea(
    Map<String, dynamic> json,
    List<AreaDisciplinaEntry> disciplinas,
  ) {
    final areaId = _readString(json, const <String>['idArea', 'id_area']);
    final style = _resolveStyle(areaId);
    final sortedDisciplinas = [...disciplinas]
      ..sort((left, right) => left.nome.toLowerCase().compareTo(right.nome.toLowerCase()));
    final role = _readString(json, const <String>['targetRole', 'target_role', 'TargetRole']);

    return AreaDisciplinasItem(
      idArea: areaId,
      nome: _readString(json, const <String>['nome', 'name']),
      targetRole: role.isNotEmpty ? role : 'ensino', // NOVO
      explicadores: _readInt(json, const <String>['professorCount', 'professor_count']),
      disciplinas: sortedDisciplinas,
      icon: style.icon,
      iconBackgroundColor: style.iconBackgroundColor,
      iconColor: style.iconColor,
    );
  }

  AreaDisciplinaEntry _mapDisciplina(Map<String, dynamic> json) {
    return AreaDisciplinaEntry(
      idDisciplina: _readString(json, const <String>['idDisciplina', 'id_disciplina']),
      idArea: _readString(json, const <String>['idArea', 'id_area']),
      nome: _readString(json, const <String>['nome', 'name']),
    );
  }

  _AreaVisualStyle _resolveStyle(String seed) {
    final normalizedSeed = seed.trim();
    final index = normalizedSeed.isEmpty
        ? 0
        : normalizedSeed.codeUnits.fold<int>(0, (sum, code) => sum + code) %
            _visualStyles.length;
    return _visualStyles[index];
  }

  Future<void> _createDisciplina({
    required String areaId,
    required String disciplinaName,
    required String token,
  }) {
    return _apiClient.postJson(
      ApiConfig.uri('/api/Education/disciplinas'),
      token: token,
      body: <String, dynamic>{
        'idArea': areaId,
        'nome': disciplinaName,
        'descricao': null,
      },
    );
  }

  Future<String> _requireToken() async {
    await _sessionController.initialize();
    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      throw Exception('Sem sessao de administrador ativa.');
    }

    return token;
  }

  List<String> _normalizeNames(List<String> values) {
    final result = <String>[];
    final seen = <String>{};

    for (final rawValue in values) {
      final value = rawValue.trim();
      if (value.isEmpty) {
        continue;
      }

      final normalized = _normalizeValue(value);
      if (seen.add(normalized)) {
        result.add(value);
      }
    }

    return result;
  }

  String _normalizeValue(String value) => value.trim().toLowerCase();

  String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key]?.toString().trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }

      final parsed = int.tryParse(value?.toString() ?? '');
      if (parsed != null) {
        return parsed;
      }
    }

    return 0;
  }
}

class _AreaVisualStyle {
  const _AreaVisualStyle({
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
}