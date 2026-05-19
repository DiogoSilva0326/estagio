import 'dart:convert';

import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:http/http.dart' as http;

class NewsletterActionResult {
  const NewsletterActionResult({
    required this.success,
    required this.message,
  });

  final bool success;
  final String message;
}

class NewsletterApi {
  Future<NewsletterActionResult> subscribe({
    required String email,
    String? locale,
    String source = 'footer',
  }) async {
    final response = await http.post(
      ApiConfig.uri('/api/Newsletter/subscribe'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{
        'email': email.trim(),
        'locale': (locale == null || locale.trim().isEmpty)
            ? 'pt-PT'
            : locale.trim(),
        'source': source,
      }),
    );

    return _parseActionResponse(
      response,
      fallbackMessage: 'Não foi possível concluir a subscrição.',
    );
  }

  Future<NewsletterActionResult> confirm(String token) {
    return _getAction(
      '/api/Newsletter/confirm',
      token,
      fallbackMessage: 'Não foi possível confirmar a subscrição.',
    );
  }

  Future<NewsletterActionResult> unsubscribe(String token) {
    return _getAction(
      '/api/Newsletter/unsubscribe',
      token,
      fallbackMessage: 'Não foi possível cancelar a subscrição.',
    );
  }

  Future<NewsletterActionResult> requestUnsubscribeByEmail({
    required String email,
  }) async {
    final response = await http.post(
      ApiConfig.uri('/api/Newsletter/unsubscribe-request'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(<String, dynamic>{'email': email.trim()}),
    );

    return _parseActionResponse(
      response,
      fallbackMessage: 'Não foi possível pedir o cancelamento da subscrição.',
    );
  }

  Future<NewsletterActionResult> _getAction(
    String path,
    String token, {
    required String fallbackMessage,
  }) async {
    final response = await http.get(
      ApiConfig.uri(path).replace(
        queryParameters: <String, String>{'token': token.trim()},
      ),
      headers: const {'Content-Type': 'application/json'},
    );

    return _parseActionResponse(
      response,
      fallbackMessage: fallbackMessage,
    );
  }

  NewsletterActionResult _parseActionResponse(
    http.Response response, {
    required String fallbackMessage,
  }) {
    Map<String, dynamic>? payload;

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
      }
    } catch (_) {}

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NewsletterApiException(
        '${_extractMessage(payload, fallbackMessage)} (${response.statusCode})',
      );
    }

    return NewsletterActionResult(
      success: payload?['success'] == true,
      message: _extractMessage(payload, fallbackMessage),
    );
  }

  String _extractMessage(
    Map<String, dynamic>? payload,
    String fallbackMessage,
  ) {
    if (payload == null) {
      return fallbackMessage;
    }

    final message = payload['message'] ?? payload['error'];
    if (message == null) {
      return fallbackMessage;
    }

    final normalized = message.toString().trim();
    return normalized.isEmpty ? fallbackMessage : normalized;
  }
}

class NewsletterApiException implements Exception {
  const NewsletterApiException(this.message);

  final String message;

  @override
  String toString() => message;
}