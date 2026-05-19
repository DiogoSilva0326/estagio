import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../models/newsletter_campaign.dart';
import '../models/newsletter_subscriber.dart';

class BackofficeNewsletterViewData {
  const BackofficeNewsletterViewData({
    required this.subscriberCount,
    required this.subscribers,
    required this.items,
    this.warningMessage,
  });

  final int subscriberCount;
  final List<NewsletterSubscriber> subscribers;
  final List<NewsletterCampaign> items;
  final String? warningMessage;
}

class NewsletterCampaignDraft {
  const NewsletterCampaignDraft({
    required this.title,
    required this.subject,
    required this.segment,
    required this.htmlBody,
  });

  final String title;
  final String subject;
  final String segment;
  final String htmlBody;
}

class BackofficeNewsletterService {
  BackofficeNewsletterService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  })  : _apiClient = apiClient ?? BackofficeApiClient(),
        _sessionController =
            sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<BackofficeNewsletterViewData> fetch() async {
    await _sessionController.initialize();

    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      return const BackofficeNewsletterViewData(
        subscriberCount: 0,
        subscribers: <NewsletterSubscriber>[],
        items: <NewsletterCampaign>[],
        warningMessage:
            'Sem sessão de administrador ativa. Inicie sessão para carregar a newsletter.',
      );
    }

    try {
      final countPayload = await _apiClient.getJson(
        ApiConfig.uri('/api/Newsletter/subscribers/count'),
        token: token,
      );
      final subscribersPayload = await _apiClient.getJsonList(
        ApiConfig.uri('/api/Newsletter/subscribers?pageNumber=1&pageSize=100'),
        token: token,
      );
      final campaignsPayload = await _apiClient.getJsonList(
        ApiConfig.uri('/api/Newsletter/campaigns?pageNumber=1&pageSize=50'),
        token: token,
      );

      return BackofficeNewsletterViewData(
        subscriberCount: (countPayload['count'] as num?)?.toInt() ?? 0,
        subscribers: subscribersPayload
            .whereType<Map>()
            .map((item) => NewsletterSubscriber.fromJson(item.cast<String, dynamic>()))
            .toList(growable: false),
        items: campaignsPayload
            .whereType<Map>()
            .map((item) => NewsletterCampaign.fromJson(item.cast<String, dynamic>()))
            .toList(growable: false),
      );
    } catch (_) {
      return const BackofficeNewsletterViewData(
        subscriberCount: 0,
        subscribers: <NewsletterSubscriber>[],
        items: <NewsletterCampaign>[],
        warningMessage:
            'Não foi possível sincronizar a newsletter com a API. Verifique se os endpoints de newsletter já estão disponíveis neste projeto.',
      );
    }
  }

  Future<NewsletterCampaign> createCampaign(NewsletterCampaignDraft draft) async {
    final token = await _validatedToken();
    final payload = await _apiClient.postJson(
      ApiConfig.uri('/api/Newsletter/campaigns'),
      token: token,
      body: <String, dynamic>{
        'title': draft.title,
        'subject': draft.subject,
        'segment': draft.segment,
        'htmlBody': draft.htmlBody,
        'plainBody': _stripHtml(draft.htmlBody),
      },
    );

    final id = payload['id']?.toString().trim() ?? '';
    if (id.isEmpty) {
      throw const FormatException('A API não devolveu o identificador da campanha criada.');
    }

    final campaignPayload = await _apiClient.getJson(
      ApiConfig.uri('/api/Newsletter/campaigns/$id'),
      token: token,
    );

    return NewsletterCampaign.fromJson(campaignPayload);
  }

  Future<NewsletterCampaign> fetchCampaignById(String campaignId) async {
    final token = await _validatedToken();
    final payload = await _apiClient.getJson(
      ApiConfig.uri('/api/Newsletter/campaigns/$campaignId'),
      token: token,
    );

    return NewsletterCampaign.fromJson(payload);
  }

  Future<NewsletterCampaign> updateCampaign(
    String campaignId,
    NewsletterCampaignDraft draft,
  ) async {
    final token = await _validatedToken();
    await _apiClient.putJson(
      ApiConfig.uri('/api/Newsletter/campaigns/$campaignId'),
      token: token,
      body: <String, dynamic>{
        'title': draft.title,
        'subject': draft.subject,
        'segment': draft.segment,
        'htmlBody': draft.htmlBody,
        'plainBody': _stripHtml(draft.htmlBody),
      },
    );

    return fetchCampaignById(campaignId);
  }

  Future<Map<String, int>> sendCampaign(String campaignId) async {
    final token = await _validatedToken();
    final payload = await _apiClient.postJson(
      ApiConfig.uri('/api/Newsletter/campaigns/$campaignId/send'),
      token: token,
    );

    return <String, int>{
      'sent': (payload['sent'] as num?)?.toInt() ?? 0,
      'failed': (payload['failed'] as num?)?.toInt() ?? 0,
    };
  }

  Future<String> _validatedToken() async {
    await _sessionController.initialize();

    final token = _sessionController.token;
    if (!_sessionController.isAuthenticated || token == null || token.isEmpty) {
      throw Exception('Sem sessão de administrador ativa.');
    }

    return token;
  }

  static String _stripHtml(String value) {
    return value
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}