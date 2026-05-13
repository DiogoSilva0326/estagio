import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../models/faq_item.dart';

class BackofficeFaqsService {
  BackofficeFaqsService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  })  : _apiClient = apiClient ?? BackofficeApiClient(),
        _sessionController =
            sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<List<FaqItem>> fetchFaqs() async {
    final token = await _validatedToken();
    final payload = await _apiClient.getJsonList(
      ApiConfig.uri('/api/Faq/admin'),
      token: token,
    );

    return payload
        .whereType<Map>()
        .map((item) => _mapFaqItem(item.cast<String, dynamic>()))
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<FaqCategoryOption>> fetchCategories() async {
    final token = await _validatedToken();
    final payload = await _apiClient.getJsonList(
      ApiConfig.uri('/api/Faq/admin/categories'),
      token: token,
    );

    return payload
        .whereType<Map>()
        .map((item) => _mapCategory(item.cast<String, dynamic>()))
        .where((item) => item.id.isNotEmpty && item.label.isNotEmpty)
        .toList(growable: false);
  }

  Future<FaqCategoryOption> createCategory({
    required String label,
    String? description,
  }) async {
    final token = await _validatedToken();
    final payload = await _apiClient.postJson(
      ApiConfig.uri('/api/Faq/admin/categories'),
      token: token,
      body: <String, dynamic>{
        'name': label.trim(),
        'description': description?.trim(),
      },
    );

    return _mapCategory(payload);
  }

  Future<FaqItem> createFaq({
    required String categoryId,
    required String categoryLabel,
    required String question,
    required String answer,
  }) async {
    final token = await _validatedToken();
    final payload = await _apiClient.postJson(
      ApiConfig.uri('/api/Faq/admin'),
      token: token,
      body: <String, dynamic>{
        'idFaqCategory': categoryId,
        'question': question.trim(),
        'description': answer.trim(),
      },
    );

    return _mapFaqItem(payload, fallbackCategoryLabel: categoryLabel);
  }

  Future<FaqItem> updateFaq({
    required String id,
    required String categoryId,
    required String categoryLabel,
    required String question,
    required String answer,
  }) async {
    final token = await _validatedToken();
    final payload = await _apiClient.putJson(
      ApiConfig.uri('/api/Faq/admin/$id'),
      token: token,
      body: <String, dynamic>{
        'idFaqCategory': categoryId,
        'question': question.trim(),
        'description': answer.trim(),
      },
    );

    if (payload.isEmpty) {
      return FaqItem(
        id: id,
        categoryId: categoryId,
        categoryLabel: categoryLabel,
        question: question.trim(),
        answer: answer.trim(),
        status: FaqStatus.published,
        updatedAtLabel: _formatDateLabel(DateTime.now().toUtc()),
      );
    }

    return _mapFaqItem(payload, fallbackCategoryLabel: categoryLabel);
  }

  Future<void> deleteFaq(String id) async {
    final token = await _validatedToken();
    await _apiClient.delete(
      ApiConfig.uri('/api/Faq/admin/$id'),
      token: token,
    );
  }

  FaqCategoryOption _mapCategory(Map<String, dynamic> json) {
    return FaqCategoryOption(
      id: (json['idFaqCategory'] ?? json['IdFaqCategory'] ?? json['id_faq_category'])
              ?.toString() ??
          '',
      label: (json['category'] ?? json['Category'] ?? json['name'] ?? json['Name'])
              ?.toString()
              .trim() ??
          '',
      description: (json['description'] ?? json['Description'])?.toString(),
    );
  }

  FaqItem _mapFaqItem(
    Map<String, dynamic> json, {
    String? fallbackCategoryLabel,
  }) {
    final updatedAt = _tryParseDateTime(
      json['updatedAt'] ?? json['UpdatedAt'] ?? json['updated_at'],
    );
    final createdAt = _tryParseDateTime(
      json['createdAt'] ?? json['CreatedAt'] ?? json['created_at'],
    );

    return FaqItem(
      id: (json['idFaq'] ?? json['IdFaq'] ?? json['id_faq'])?.toString() ?? '',
      categoryId: (json['idFaqCategory'] ??
                  json['IdFaqCategory'] ??
                  json['id_faq_category'])
              ?.toString() ??
          '',
      categoryLabel: (json['categoryName'] ??
                  json['CategoryName'] ??
                  json['category'] ??
                  json['Category'])
              ?.toString()
              .trim() ??
          (fallbackCategoryLabel ?? ''),
      question: (json['question'] ?? json['Question'])?.toString().trim() ?? '',
      answer:
          (json['description'] ?? json['Description'])?.toString().trim() ?? '',
      status: FaqStatus.published,
      updatedAtLabel: _formatDateLabel(updatedAt ?? createdAt ?? DateTime.now().toUtc()),
    );
  }

  DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  String _formatDateLabel(DateTime value) {
    final local = value.toLocal();
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

    final month = months[local.month] ?? local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.day.toString().padLeft(2, '0')} $month ${local.year} · $hour:$minute';
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