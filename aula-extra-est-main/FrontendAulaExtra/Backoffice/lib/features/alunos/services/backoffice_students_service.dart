import 'package:flutter/material.dart';

import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../models/aluno_item.dart';

class BackofficeStudentsViewData {
  const BackofficeStudentsViewData({
    required this.items,
    this.warningMessage,
  });

  final List<AlunoItem> items;
  final String? warningMessage;
}

class BackofficeStudentsService {
  BackofficeStudentsService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  })  : _apiClient = apiClient ?? BackofficeApiClient(),
        _sessionController =
            sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<BackofficeStudentsViewData> fetch() async {
    await _sessionController.initialize();

    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      return const BackofficeStudentsViewData(
        items: <AlunoItem>[],
        warningMessage:
            'Sem sessão de administrador ativa. Inicie sessão para carregar estes alunos.',
      );
    }

    try {
      final payload = await _apiClient.getJson(
        ApiConfig.uri('/api/Users/admin-directory'),
        token: token,
      );

      final rawItems = (payload['items'] as List?) ?? const <dynamic>[];
      return BackofficeStudentsViewData(
        items: rawItems
            .whereType<Map>()
            .map((item) => _mapItem(item.cast<String, dynamic>()))
            .toList(growable: false),
      );
    } catch (_) {
      return const BackofficeStudentsViewData(
        items: <AlunoItem>[],
        warningMessage:
            'Não foi possível sincronizar a lista de alunos com a API. Tente novamente.',
      );
    }
  }

  AlunoItem _mapItem(Map<String, dynamic> json) {
    final name = _stringValue(json['name'], fallback: 'Aluno');
    final statusLabel = _stringValue(json['statusLabel'], fallback: 'ATIVO').toUpperCase();
    final isInactive = statusLabel == 'INATIVO';
    final sessionsCount = _intValue(json['sessionsCount']);
    final activeLessonPacks = _intValue(json['activeLessonPacks']);
    final schoolYear = _stringValue(json['schoolYear'], fallback: '—');
    final planLabel = activeLessonPacks > 0
        ? '$activeLessonPacks plano(s) ativo(s)'
        : _stringValue(json['planLabel'], fallback: 'Sem plano ativo');
    final accountState = _stringValue(json['accountStateLabel'], fallback: 'Conta ativa');

    return AlunoItem(
      initials: _buildInitials(name),
      name: name,
      email: _stringValue(json['email'], fallback: '-'),
      schoolYear: schoolYear,
      planLabel: planLabel,
      sessionsLabel: sessionsCount > 0 ? '$sessionsCount sessões' : '0 sessões',
      statusLabel: accountState,
      statusColor: isInactive ? const Color(0xFFED1C24) : const Color(0xFF4CAF50),
      statusBackgroundColor: isInactive
          ? const Color(0x26FFBDC0)
          : const Color(0x264CAF50),
    );
  }

  String _stringValue(Object? value, {required String fallback}) {
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? fallback : normalized;
  }

  int _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _buildInitials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();

    return parts.isEmpty ? 'AE' : parts;
  }
}