import 'package:aula_extra/core/data/faq/dtos/faq_category_dto.dart';
import 'package:aula_extra/core/data/faq/dtos/faq_item_dto.dart';
import 'package:aula_extra/core/data/faq/faq_api.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class FaqService {
  FaqService({FaqApi? api, TokenStorage? tokenStorage})
    : _api = api ?? FaqApi(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final FaqApi _api;
  final TokenStorage _tokenStorage;

  Future<List<FaqItemDto>> getPublicFaqs({String? idFaqCategory, String? query}) {
    return _api.getPublicFaqs(idFaqCategory: idFaqCategory, query: query);
  }

  Future<List<FaqCategoryDto>> getPublicCategories() {
    return _api.getPublicCategories();
  }

  Future<List<FaqItemDto>> getFaqs() async {
    final token = await _requireToken();
    return _api.getFaqs(token: token);
  }

  Future<FaqItemDto> createFaq({
    required String idFaqCategory,
    required String question,
    required String description,
  }) async {
    final token = await _requireToken();
    return _api.createFaq(
      token: token,
      input: UpsertFaqInput(
        idFaqCategory: idFaqCategory,
        question: question.trim(),
        description: description.trim(),
      ),
    );
  }

  Future<void> updateFaq({
    required String idFaq,
    required String idFaqCategory,
    required String question,
    required String description,
  }) async {
    final token = await _requireToken();
    return _api.updateFaq(
      token: token,
      idFaq: idFaq,
      input: UpsertFaqInput(
        idFaqCategory: idFaqCategory,
        question: question.trim(),
        description: description.trim(),
      ),
    );
  }

  Future<void> deleteFaq({required String idFaq}) async {
    final token = await _requireToken();
    return _api.deleteFaq(token: token, idFaq: idFaq);
  }

  Future<List<FaqCategoryDto>> getCategories() async {
    final token = await _requireToken();
    return _api.getCategories(token: token);
  }

  Future<FaqCategoryDto> createCategory({
    required String name,
    String? description,
  }) async {
    final token = await _requireToken();
    return _api.createCategory(
      token: token,
      input: UpsertFaqCategoryInput(
        name: name.trim(),
        description: description?.trim().isEmpty ?? true ? null : description?.trim(),
      ),
    );
  }

  Future<void> updateCategory({
    required String idFaqCategory,
    required String name,
    String? description,
  }) async {
    final token = await _requireToken();
    return _api.updateCategory(
      token: token,
      idFaqCategory: idFaqCategory,
      input: UpsertFaqCategoryInput(
        name: name.trim(),
        description: description?.trim().isEmpty ?? true ? null : description?.trim(),
      ),
    );
  }

  Future<void> deleteCategory({required String idFaqCategory}) async {
    final token = await _requireToken();
    return _api.deleteCategory(token: token, idFaqCategory: idFaqCategory);
  }

  Future<String> _requireToken() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const FaqException('Sessão expirada');
    }
    return token;
  }
}
