import 'dart:convert';

import 'package:aula_extra/core/data/faq/dtos/faq_category_dto.dart';
import 'package:aula_extra/core/data/faq/dtos/faq_item_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:http/http.dart' as http;

class UpsertFaqInput {
  UpsertFaqInput({
    required this.idFaqCategory,
    required this.question,
    required this.description,
  });

  final String idFaqCategory;
  final String question;
  final String description;

  Map<String, dynamic> toJson() => {
    'idFaqCategory': idFaqCategory,
    'question': question,
    'description': description,
  };
}

class UpsertFaqCategoryInput {
  UpsertFaqCategoryInput({required this.name, this.description});

  final String name;
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
  };
}

class FaqApi {
  Future<List<FaqItemDto>> getPublicFaqs({String? idFaqCategory, String? query}) async {
    final params = <String, String>{};
    final normalizedCategoryId = idFaqCategory?.trim();
    final normalizedQuery = query?.trim();

    if (normalizedCategoryId != null && normalizedCategoryId.isNotEmpty) {
      params['categoryId'] = normalizedCategoryId;
    }
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      params['q'] = normalizedQuery;
    }

    final res = await http.get(
      ApiConfig.uri('/api/Faq').replace(queryParameters: params.isEmpty ? null : params),
      headers: const {'Content-Type': 'application/json'},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao carregar FAQs (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <FaqItemDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(FaqItemDto.fromJson)
        .where(
          (item) =>
              item.idFaq.trim().isNotEmpty &&
            item.idFaqCategory.trim().isNotEmpty &&
              item.question.trim().isNotEmpty &&
            item.categoryName.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<List<FaqCategoryDto>> getPublicCategories() async {
    final res = await http.get(
      ApiConfig.uri('/api/Faq/categories'),
      headers: const {'Content-Type': 'application/json'},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao carregar categorias FAQ (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <FaqCategoryDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(FaqCategoryDto.fromJson)
        .where(
          (item) =>
              item.idFaqCategory.trim().isNotEmpty &&
              item.category.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  Future<List<FaqItemDto>> getFaqs({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Faq/admin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) throw const FaqException('Sessão expirada');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao carregar FAQs (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <FaqItemDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(FaqItemDto.fromJson)
        .toList(growable: false);
  }

  Future<FaqItemDto> createFaq({required String token, required UpsertFaqInput input}) async {
    final res = await http.post(
      ApiConfig.uri('/api/Faq/admin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(input.toJson()),
    );

    if (res.statusCode == 401) throw const FaqException('Sessão expirada');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao criar FAQ (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! Map<String, dynamic>) {
      throw const FaqException('Resposta inválida do servidor');
    }

    return FaqItemDto.fromJson(data);
  }

  Future<void> updateFaq({
    required String token,
    required String idFaq,
    required UpsertFaqInput input,
  }) async {
    final res = await http.put(
      ApiConfig.uri('/api/Faq/admin/$idFaq'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(input.toJson()),
    );

    if (res.statusCode == 401) throw const FaqException('Sessão expirada');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao atualizar FAQ (${res.statusCode})');
    }
  }

  Future<void> deleteFaq({required String token, required String idFaq}) async {
    final res = await http.delete(
      ApiConfig.uri('/api/Faq/admin/$idFaq'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) throw const FaqException('Sessão expirada');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao eliminar FAQ (${res.statusCode})');
    }
  }

  Future<List<FaqCategoryDto>> getCategories({required String token}) async {
    final res = await http.get(
      ApiConfig.uri('/api/Faq/admin/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) throw const FaqException('Sessão expirada');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao carregar categorias FAQ (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! List) return <FaqCategoryDto>[];

    return data
        .whereType<Map<String, dynamic>>()
        .map(FaqCategoryDto.fromJson)
        .toList(growable: false);
  }

  Future<FaqCategoryDto> createCategory({
    required String token,
    required UpsertFaqCategoryInput input,
  }) async {
    final res = await http.post(
      ApiConfig.uri('/api/Faq/admin/categories'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(input.toJson()),
    );

    if (res.statusCode == 401) throw const FaqException('Sessão expirada');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao criar categoria FAQ (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! Map<String, dynamic>) {
      throw const FaqException('Resposta inválida do servidor');
    }

    return FaqCategoryDto.fromJson(data);
  }

  Future<void> updateCategory({
    required String token,
    required String idFaqCategory,
    required UpsertFaqCategoryInput input,
  }) async {
    final res = await http.put(
      ApiConfig.uri('/api/Faq/admin/categories/$idFaqCategory'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(input.toJson()),
    );

    if (res.statusCode == 401) throw const FaqException('Sessão expirada');
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao atualizar categoria FAQ (${res.statusCode})');
    }
  }

  Future<void> deleteCategory({
    required String token,
    required String idFaqCategory,
  }) async {
    final res = await http.delete(
      ApiConfig.uri('/api/Faq/admin/categories/$idFaqCategory'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 401) throw const FaqException('Sessão expirada');
    if (res.statusCode == 409) {
      throw const FaqException('Não é possível eliminar a categoria porque ainda existem FAQs associadas.');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw FaqException('Falha ao eliminar categoria FAQ (${res.statusCode})');
    }
  }
}

class FaqException implements Exception {
  const FaqException(this.message);

  final String message;

  @override
  String toString() => message;
}
