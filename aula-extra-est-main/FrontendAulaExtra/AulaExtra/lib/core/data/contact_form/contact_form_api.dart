import 'dart:convert';

import 'package:aula_extra/core/data/contact_form/dtos/contact_form_category_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:http/http.dart' as http;

class CreateContactFormSubmissionInput {
  CreateContactFormSubmissionInput({
    required this.idContactFormCategory,
    required this.name,
    required this.email,
    required this.message,
  });

  final String idContactFormCategory;
  final String name;
  final String email;
  final String message;

  Map<String, dynamic> toJson() => {
    'idContactFormCategory': idContactFormCategory,
    'name': name,
    'email': email,
    'message': message,
  };
}

class ContactFormApi {
  Future<List<ContactFormCategoryDto>> getCategories() async {
    final res = await http.get(
      ApiConfig.uri('/api/ContactsForm/categories'),
      headers: const {'Content-Type': 'application/json'},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ContactFormException(
        'Falha ao carregar assuntos (${res.statusCode})',
      );
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <ContactFormCategoryDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(ContactFormCategoryDto.fromJson)
        .where(
          (item) =>
              item.idContactFormCategory.trim().isNotEmpty &&
              item.name.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<void> createSubmission({
    required CreateContactFormSubmissionInput input,
    String? token,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final normalizedToken = token?.trim();
    if (normalizedToken != null && normalizedToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $normalizedToken';
    }

    final res = await http.post(
      ApiConfig.uri('/api/ContactsForm/submissions/public'),
      headers: headers,
      body: jsonEncode(input.toJson()),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ContactFormException(_extractErrorMessage(res));
    }
  }

  String _extractErrorMessage(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {}

    return 'Falha ao enviar mensagem (${res.statusCode})';
  }
}

class ContactFormException implements Exception {
  const ContactFormException(this.message);

  final String message;

  @override
  String toString() => message;
}
