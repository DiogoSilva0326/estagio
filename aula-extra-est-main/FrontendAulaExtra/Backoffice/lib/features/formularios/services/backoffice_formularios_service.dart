import 'package:flutter/material.dart';

import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../../../design/theme/app_colors.dart';
import '../models/formulario_item.dart';

class BackofficeFormulariosService {
  BackofficeFormulariosService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  }) : _apiClient = apiClient ?? BackofficeApiClient(),
       _sessionController =
           sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<List<FormularioItem>> fetchSubmissions() async {
    final token = await _validatedToken();
    final response = await _apiClient.getJsonList(
      ApiConfig.uri('/api/ContactsForm/submissions'),
      token: token,
    );
    return response
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .map((item) => _mapSubmission(item))
        .whereType<FormularioItem>()
        .toList();
  }

  FormularioItem? _mapSubmission(Map<String, dynamic> item) {
    final id = item['idContactFormSubmission']?.toString();
    if (id == null || id.isEmpty) {
      return null;
    }

    final createdAt = _parseDate(item['createdAt']?.toString());
    final status = (item['status']?.toString() ?? '').trim();
    final style = _FormularioStatusMapper.fromRaw(status);
    final subject = (item['subject']?.toString() ?? '').trim();
    final fallbackName = (item['name']?.toString() ?? '').trim();
    final email = (item['email']?.toString() ?? '').trim();

    return FormularioItem(
      submissionId: id,
      id: '#${id.substring(0, 8).toUpperCase()}',
      dateLabel: _formatDateLabel(createdAt),
      profileName: fallbackName.isEmpty ? 'Sem nome disponível' : fallbackName,
      profileEmail: email.isEmpty ? 'Sem email disponível' : email,
      formName: subject.isEmpty ? 'Formulário sem assunto' : subject,
      statusRaw: status,
      statusLabel: style.label,
      statusColor: style.color,
      statusBackgroundColor: style.backgroundColor,
      message: (item['message']?.toString() ?? '').trim().isEmpty
          ? 'Sem mensagem disponível.'
          : item['message'].toString().trim(),
    );
  }

  Future<void> markAsRead(String submissionId) async {
    final token = await _validatedToken();
    await _apiClient.postAny(
      ApiConfig.uri('/api/ContactsForm/submissions/$submissionId/reply'),
      token: token,
      body: const <String, dynamic>{'status': 'lida'},
    );
  }

  Future<void> replyToSubmission(String submissionId, String responseMessage) async {
    final token = await _validatedToken();
    await _apiClient.postAny(
      ApiConfig.uri('/api/ContactsForm/submissions/$submissionId/reply'),
      token: token,
      body: <String, dynamic>{
        'status': 'respondida',
        'responseMessage': responseMessage,
      },
    );
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw)?.toLocal();
  }

  String _formatDateLabel(DateTime? value) {
    if (value == null) {
      return 'Sem data';
    }

    const months = <int, String>{
      1: 'Jan',
      2: 'Fev',
      3: 'Mar',
      4: 'Abr',
      5: 'Mai',
      6: 'Jun',
      7: 'Jul',
      8: 'Ago',
      9: 'Set',
      10: 'Out',
      11: 'Nov',
      12: 'Dez',
    };

    final month = months[value.month] ?? value.month.toString().padLeft(2, '0');
    return '${value.day.toString().padLeft(2, '0')} $month';
  }

  Future<String> _validatedToken() async {
    await _sessionController.initialize();
    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      throw Exception('Sem sessão de administrador ativa.');
    }

    return token;
  }
}

class _FormularioStatusStyle {
  const _FormularioStatusStyle({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
}

class _FormularioStatusMapper {
  static _FormularioStatusStyle fromRaw(String raw) {
    switch (raw.toLowerCase()) {
      case 'respondida':
        return const _FormularioStatusStyle(
          label: 'Respondida',
          color: AppColors.success,
          backgroundColor: Color(0xFFEAFBF3),
        );
      case 'arquivada':
        return const _FormularioStatusStyle(
          label: 'Arquivada',
          color: AppColors.textSecondary,
          backgroundColor: Color(0xFFF3F4F6),
        );
      case 'lida':
        return const _FormularioStatusStyle(
          label: 'Lida',
          color: AppColors.accent,
          backgroundColor: Color(0xFFEEF2FF),
        );
      case 'não lida':
      case 'nao lida':
      default:
        return const _FormularioStatusStyle(
          label: 'Não lida',
          color: AppColors.warning,
          backgroundColor: Color(0xFFFFF4E5),
        );
    }
  }
}