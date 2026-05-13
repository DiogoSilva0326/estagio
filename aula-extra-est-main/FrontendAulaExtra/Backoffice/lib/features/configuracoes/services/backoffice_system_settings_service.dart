import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';

class BackofficeSystemSetting {
  const BackofficeSystemSetting({
    required this.id,
    required this.key,
    this.value,
    this.dataType,
    this.description,
  });

  final String id;
  final String key;
  final String? value;
  final String? dataType;
  final String? description;

  factory BackofficeSystemSetting.fromJson(Map<String, dynamic> json) {
    return BackofficeSystemSetting(
      id: json['id']?.toString() ?? '',
      key: json['settingsKey']?.toString() ?? json['settings_key']?.toString() ?? '',
      value: json['settingsValue']?.toString() ?? json['settings_value']?.toString(),
      dataType: json['dataType']?.toString() ?? json['data_type']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class BackofficeSystemSettingDraft {
  const BackofficeSystemSettingDraft({
    required this.key,
    required this.value,
    required this.dataType,
    required this.description,
  });

  final String key;
  final String value;
  final String dataType;
  final String description;
}

class BackofficeSystemSettingsService {
  BackofficeSystemSettingsService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  })  : _apiClient = apiClient ?? BackofficeApiClient(),
        _sessionController =
            sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<List<BackofficeSystemSetting>> fetchAll() async {
    final token = await _validatedToken();
    final payload = await _apiClient.getJsonList(
      ApiConfig.uri('/api/SystemSettings?pageNumber=1&pageSize=200'),
      token: token,
    );

    return payload
        .whereType<Map>()
        .map((item) => BackofficeSystemSetting.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<void> upsertMany(List<BackofficeSystemSettingDraft> items) async {
    final token = await _validatedToken();
    final current = await fetchAll();

    for (final item in items) {
      BackofficeSystemSetting? existing;
      for (final setting in current) {
        if (setting.key.toLowerCase() == item.key.toLowerCase()) {
          existing = setting;
          break;
        }
      }

      if (existing == null || existing.id.isEmpty) {
        await _apiClient.postAny(
          ApiConfig.uri('/api/SystemSettings'),
          token: token,
          body: <String, dynamic>{
            'settingsKey': item.key,
            'settingsValue': item.value,
            'dataType': item.dataType,
            'description': item.description,
          },
        );
      } else {
        await _apiClient.putJson(
          ApiConfig.uri('/api/SystemSettings'),
          token: token,
          body: <String, dynamic>{
            'id': existing.id,
            'settingsKey': item.key,
            'settingsValue': item.value,
            'dataType': item.dataType,
            'description': item.description,
          },
        );
      }
    }
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