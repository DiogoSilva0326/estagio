import 'package:aula_extra/core/data/payments/dtos/payment_dispute_request_dto.dart';
import 'package:aula_extra/core/data/payments/dtos/payment_summary_dto.dart';
import 'package:aula_extra/core/data/payments/dtos/professor_payment_dto.dart';
import 'package:aula_extra/core/data/payments/dtos/student_topup_simulation_request_dto.dart';
import 'package:aula_extra/core/data/payments/payments_api.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class PaymentsService {
  PaymentsService({PaymentsApi? api, TokenStorage? tokenStorage})
    : _api = api ?? PaymentsApi(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final PaymentsApi _api;
  final TokenStorage _tokenStorage;

  Future<PaymentSummaryDto> fetchMySummary() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const PaymentsException('Sessão expirada');
    }

    return _api.getMySummary(token: token);
  }

  Future<ProfessorPaymentSummaryDto> fetchMyTeacherSummary() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const PaymentsException('Sessão expirada');
    }

    return _api.getMyTeacherSummary(token: token);
  }

  Future<ProfessorPaymentDetailsDto> fetchMyTeacherPaymentDetails(
    String paymentId,
  ) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const PaymentsException('Sessão expirada');
    }

    return _api.getMyTeacherPaymentDetails(token: token, paymentId: paymentId);
  }

  Future<PaymentSummaryDto> simulateMyTopup(
    StudentTopupSimulationRequestDto request,
  ) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const PaymentsException('Sessão expirada');
    }

    return _api.simulateMyTopup(token: token, request: request);
  }

  Future<void> createMyDispute(PaymentDisputeRequestDto request) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const PaymentsException('Sessão expirada');
    }

    return _api.createMyDispute(token: token, request: request);
  }
}
