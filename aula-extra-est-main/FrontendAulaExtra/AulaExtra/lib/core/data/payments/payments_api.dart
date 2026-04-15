import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/payments/dtos/payment_summary_dto.dart';
import 'package:aula_extra/core/data/payments/dtos/payment_dispute_request_dto.dart';
import 'package:aula_extra/core/data/payments/dtos/professor_payment_dto.dart';
import 'package:aula_extra/core/data/payments/dtos/student_topup_simulation_request_dto.dart';
import 'package:http/http.dart' as http;

class PaymentsApi {
  Future<PaymentSummaryDto> getMySummary({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Payments/me/summary'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const PaymentsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw PaymentsException(
        'Falha ao carregar pagamentos (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const PaymentsException('Resposta inválida do servidor');
    }

    return PaymentSummaryDto.fromJson(obj);
  }

  Future<ProfessorPaymentSummaryDto> getMyTeacherSummary({
    required String token,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Payments/me/teacher-summary'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const PaymentsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw PaymentsException(
        'Falha ao carregar pagamentos do professor (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const PaymentsException('Resposta inválida do servidor');
    }

    return ProfessorPaymentSummaryDto.fromJson(obj);
  }

  Future<ProfessorPaymentDetailsDto> getMyTeacherPaymentDetails({
    required String token,
    required String paymentId,
  }) async {
    final res = await http.get(
      ApiConfig.uri('/api/Payments/me/teacher-payments/$paymentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) {
      throw const PaymentsException('Sessão expirada');
    }
    if (res.statusCode == 404) {
      throw const PaymentsException('Pagamento não encontrado');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw PaymentsException(
        'Falha ao carregar detalhes do pagamento (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const PaymentsException('Resposta inválida do servidor');
    }

    return ProfessorPaymentDetailsDto.fromJson(obj);
  }

  Future<PaymentSummaryDto> simulateMyTopup({
    required String token,
    required StudentTopupSimulationRequestDto request,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Payments/me/topups/simulate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode == 401) {
      throw const PaymentsException('Sessão expirada');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw PaymentsException(
        'Falha ao simular compra de créditos (${res.statusCode})',
      );
    }

    final obj = jsonDecode(res.body);
    if (obj is! Map<String, dynamic>) {
      throw const PaymentsException('Resposta inválida do servidor');
    }

    return PaymentSummaryDto.fromJson(obj);
  }

  Future<void> createMyDispute({
    required String token,
    required PaymentDisputeRequestDto request,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Payments/me/disputes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode == 401) {
      throw const PaymentsException('Sessão expirada');
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw PaymentsException(_extractErrorMessage(
        res.body,
        fallback: 'Não foi possível submeter a reclamação.',
      ));
    }
  }

  String _extractErrorMessage(String body, {required String fallback}) {
    try {
      final obj = jsonDecode(body);
      if (obj is Map<String, dynamic>) {
        final message = obj['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
    } catch (_) {}

    return fallback;
  }
}

class PaymentsException implements Exception {
  const PaymentsException(this.message);

  final String message;

  @override
  String toString() => message;
}
