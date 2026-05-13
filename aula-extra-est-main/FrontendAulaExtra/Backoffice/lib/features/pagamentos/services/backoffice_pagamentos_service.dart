import '../../../core/auth/backoffice_session_controller.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/backoffice_api_client.dart';
import '../models/pagamento_item.dart';

class PagamentosOverviewData {
  const PagamentosOverviewData({
    required this.volumeTotalMes,
    required this.comissoesPlataforma,
    required this.payoutsPendentes,
    required this.transactions,
  });

  final String volumeTotalMes;
  final String comissoesPlataforma;
  final String payoutsPendentes;
  final List<PagamentoItem> transactions;
}

class BackofficePagamentosService {
  BackofficePagamentosService({
    BackofficeApiClient? apiClient,
    BackofficeSessionController? sessionController,
  }) : _apiClient = apiClient ?? BackofficeApiClient(),
       _sessionController =
           sessionController ?? BackofficeSessionController.instance;

  final BackofficeApiClient _apiClient;
  final BackofficeSessionController _sessionController;

  Future<PagamentosOverviewData> fetchOverview() async {
    final token = await _validatedToken();
    final payload = await _apiClient.getJsonList(
      ApiConfig.uri('/api/Payments/admin/overview'),
      token: token,
    );

    final items = payload
        .whereType<Map>()
        .map((item) => _mapPayment(item.cast<String, dynamic>()))
        .toList(growable: false);

    final now = DateTime.now();
    final currentMonth = items.where((item) {
      final date = _parseDate(item['paymentDate']);
      return date != null && date.year == now.year && date.month == now.month;
    }).toList(growable: false);

    final monthlyVolume = currentMonth.fold<double>(
      0,
      (sum, item) => sum + _asDouble(item['grossAmount']),
    );
    final monthlyFees = currentMonth.fold<double>(
      0,
      (sum, item) => sum + _asDouble(item['platformFeeAmount']),
    );
    final pendingPayouts = items
        .where((item) {
          final status = (item['status']?.toString() ?? '').toLowerCase();
          return status.contains('pending') ||
              status.contains('pendente') ||
              status.contains('processing');
        })
        .fold<double>(0, (sum, item) => sum + _asDouble(item['netAmount']));

    return PagamentosOverviewData(
      volumeTotalMes: _formatCurrency(monthlyVolume),
      comissoesPlataforma: _formatCurrency(monthlyFees),
      payoutsPendentes: _formatCurrency(pendingPayouts),
      transactions: items.map(_toPagamentoItem).toList(growable: false),
    );
  }

  Map<String, dynamic> _mapPayment(Map<String, dynamic> json) {
    return <String, dynamic>{
      'id': json['id']?.toString() ?? '',
      'studentName': (json['studentName']?.toString() ?? '').trim(),
      'tutorName': (json['tutorName']?.toString() ?? '').trim(),
      'subject': (json['subject']?.toString() ?? '').trim(),
      'paymentDate': json['paymentDate']?.toString(),
      'grossAmount': json['grossAmount'],
      'platformFeeAmount': json['platformFeeAmount'],
      'netAmount': json['netAmount'],
      'status': (json['status']?.toString() ?? '').trim(),
      'reference': json['reference']?.toString(),
      'currency': (json['currency']?.toString() ?? 'EUR').trim(),
    };
  }

  PagamentoItem _toPagamentoItem(Map<String, dynamic> item) {
    final paymentDate = _parseDate(item['paymentDate']);
    final gross = _asDouble(item['grossAmount']);
    final fee = _asDouble(item['platformFeeAmount']);
    final net = _asDouble(item['netAmount']);
    final percent = gross <= 0 ? 0 : (fee / gross) * 100;
    final id = item['id']?.toString() ?? '';
    final reference = item['reference']?.toString() ?? id;

    return PagamentoItem(
      id: id,
      code: '#${_shortCode(reference.isNotEmpty ? reference : id)}',
      subject: (item['subject']?.toString().isNotEmpty ?? false)
          ? item['subject'].toString()
          : 'Aula',
      paymentDate: paymentDate,
      reference: reference,
      currency: (item['currency']?.toString().isNotEmpty ?? false)
          ? item['currency'].toString()
          : 'EUR',
      grossAmountValue: gross,
      platformFeeAmountValue: fee,
      teacherAmountValue: net,
      dateLabel: _formatDateLabel(paymentDate),
      aluno: (item['studentName']?.toString().isNotEmpty ?? false)
          ? item['studentName'].toString()
          : 'Aluno',
      explicador: (item['tutorName']?.toString().isNotEmpty ?? false)
          ? item['tutorName'].toString()
          : 'Professor',
      totalAmount: _formatCurrency(gross),
      commissionLabel:
          '${_formatCurrency(fee)} (${percent.toStringAsFixed(0)}%)',
      teacherAmount: _formatCurrency(net),
      status: item['status']?.toString() ?? 'pending',
    );
  }

  String _shortCode(String value) {
    final sanitized = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (sanitized.isEmpty) {
      return 'PAGAMENTO';
    }

    return sanitized.length <= 8
        ? sanitized.toUpperCase()
        : sanitized.substring(0, 8).toUpperCase();
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw.toString())?.toLocal();
  }

  String _formatDateLabel(DateTime? value) {
    if (value == null) {
      return '-';
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

  String _formatCurrency(double value) {
    return '€ ${value.toStringAsFixed(2)}';
  }

  double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
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