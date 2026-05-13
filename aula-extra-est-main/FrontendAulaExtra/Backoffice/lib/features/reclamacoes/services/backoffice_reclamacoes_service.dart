import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../models/reclamacao_item.dart';

class BackofficeReclamacoesData {
  const BackofficeReclamacoesData({
    required this.complaints,
    required this.paymentDisputes,
  });

  final List<ReclamacaoItem> complaints;
  final List<ReclamacaoItem> paymentDisputes;
}

class BackofficeReclamacoesService {
  BackofficeReclamacoesService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  })  : _apiClient = apiClient ?? BackofficeApiClient(),
        _sessionController = sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<BackofficeReclamacoesData> fetchData() async {
    final token = await _validatedToken();
    final complaintsPayload = await _apiClient.getJsonList(
      ApiConfig.uri('/api/Complaints'),
      token: token,
    );
    final disputesPayload = await _apiClient.getJsonList(
      ApiConfig.uri('/api/Payments/disputes'),
      token: token,
    );

    final complaints = complaintsPayload
        .whereType<Map>()
        .map((item) => _mapComplaint(item.cast<String, dynamic>()))
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);

    final disputes = disputesPayload
        .whereType<Map>()
        .map((item) => _mapPaymentDispute(item.cast<String, dynamic>()))
        .where((item) => item.id.isNotEmpty)
        .toList(growable: false);

    return BackofficeReclamacoesData(
      complaints: complaints,
      paymentDisputes: disputes,
    );
  }

  Future<void> markAsRead(String complaintId) async {
    final token = await _validatedToken();
    await _apiClient.postAny(
      ApiConfig.uri('/api/Complaints/$complaintId/reply'),
      token: token,
      body: const <String, dynamic>{'status': 'lida'},
    );
  }

  Future<void> markPaymentDisputeAsRead(String disputeId) async {
    final token = await _validatedToken();
    await _apiClient.postAny(
      ApiConfig.uri('/api/Payments/disputes/$disputeId/reply'),
      token: token,
      body: const <String, dynamic>{'status': 'lida'},
    );
  }

  Future<void> replyToComplaint(String complaintId, String responseMessage) async {
    final token = await _validatedToken();
    await _apiClient.postAny(
      ApiConfig.uri('/api/Complaints/$complaintId/reply'),
      token: token,
      body: <String, dynamic>{
        'status': 'respondida',
        'responseMessage': responseMessage,
      },
    );
  }

  Future<void> replyToPaymentDispute(String disputeId, String responseMessage) async {
    final token = await _validatedToken();
    await _apiClient.postAny(
      ApiConfig.uri('/api/Payments/disputes/$disputeId/reply'),
      token: token,
      body: <String, dynamic>{
        'status': 'respondida',
        'responseMessage': responseMessage,
      },
    );
  }

  ReclamacaoItem _mapComplaint(Map<String, dynamic> json) {
    final type = (json['complaintType'] ?? json['ComplaintType'] ?? 'Suporte')
        .toString()
        .trim();
    final status = (json['status'] ?? json['Status'] ?? 'pending').toString();
    final statusStyle = status.toReclamacaoStatusStyle();

    return ReclamacaoItem(
      id: (json['idComplaint'] ?? json['IdComplaint'])?.toString() ?? '',
      source: ReclamacaoSource.utilizadores,
      dateLabel: _formatDateLabel(
        _tryParseDateTime(json['createdAt'] ?? json['CreatedAt']),
      ),
      profileName: (json['senderDisplayName'] ?? json['SenderDisplayName'])
              ?.toString()
              .trim()
              .isNotEmpty ==
          true
          ? (json['senderDisplayName'] ?? json['SenderDisplayName']).toString().trim()
          : 'Utilizador sem nome',
        profileEmail: (json['senderEmail'] ?? json['SenderEmail'])
            ?.toString()
            .trim()
            .isNotEmpty ==
          true
          ? (json['senderEmail'] ?? json['SenderEmail']).toString().trim()
          : 'Sem email disponível',
      type: type.isEmpty ? 'Suporte' : type,
        statusRaw: status,
      statusLabel: statusStyle.label,
      statusColor: statusStyle.color,
      statusBackgroundColor: statusStyle.backgroundColor,
      title: (json['complaintSubject'] ?? json['ComplaintSubject'])
              ?.toString()
              .trim()
              .isNotEmpty ==
          true
          ? (json['complaintSubject'] ?? json['ComplaintSubject']).toString().trim()
          : 'Sem assunto',
      description: (json['complaintMessage'] ?? json['ComplaintMessage'])
              ?.toString()
              .trim()
              .isNotEmpty ==
          true
          ? (json['complaintMessage'] ?? json['ComplaintMessage']).toString().trim()
          : 'Sem descrição disponível.',
    );
  }

  ReclamacaoItem _mapPaymentDispute(Map<String, dynamic> json) {
    final status = (json['status'] ?? json['Status'] ?? 'submetida').toString();
    final statusStyle = status.toReclamacaoStatusStyle();
    final paymentSource = (json['paymentSource'] ?? json['PaymentSource'] ?? 'pagamento')
        .toString()
        .trim();
    final normalizedType = paymentSource.toLowerCase() == 'reservation_payment'
        ? 'Pagamento de aula'
        : paymentSource.toLowerCase() == 'topup'
            ? 'Carregamento'
            : 'Pagamento';

    return ReclamacaoItem(
      id: (json['idDispute'] ?? json['IdDispute'])?.toString() ?? '',
      source: ReclamacaoSource.pagamentos,
      dateLabel: _formatDateLabel(
        _tryParseDateTime(json['createdAt'] ?? json['CreatedAt']),
      ),
      profileName: (json['reporterName'] ?? json['ReporterName'])
              ?.toString()
              .trim()
              .isNotEmpty ==
          true
          ? (json['reporterName'] ?? json['ReporterName']).toString().trim()
          : 'Utilizador sem nome',
      profileEmail: (json['reporterEmail'] ?? json['ReporterEmail'])
              ?.toString()
              .trim()
              .isNotEmpty ==
          true
          ? (json['reporterEmail'] ?? json['ReporterEmail']).toString().trim()
          : 'Sem email disponível',
      type: normalizedType,
        statusRaw: status,
      statusLabel: statusStyle.label,
      statusColor: statusStyle.color,
      statusBackgroundColor: statusStyle.backgroundColor,
      title: (json['subject'] ?? json['Subject'])?.toString().trim().isNotEmpty == true
          ? (json['subject'] ?? json['Subject']).toString().trim()
          : 'Reclamação de pagamento',
      description: (json['reason'] ?? json['Reason'])?.toString().trim().isNotEmpty == true
          ? (json['reason'] ?? json['Reason']).toString().trim()
          : 'Sem descrição disponível.',
    );
  }

  DateTime? _tryParseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(value.toString());
  }

  String _formatDateLabel(DateTime? value) {
    if (value == null) {
      return '-';
    }

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
    return '${local.day.toString().padLeft(2, '0')} $month';
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