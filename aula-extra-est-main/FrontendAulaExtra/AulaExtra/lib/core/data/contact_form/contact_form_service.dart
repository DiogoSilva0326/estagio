import 'package:aula_extra/core/data/contact_form/contact_form_api.dart';
import 'package:aula_extra/core/data/contact_form/dtos/contact_form_category_dto.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class ContactFormService {
  ContactFormService({ContactFormApi? api, TokenStorage? tokenStorage})
    : _api = api ?? ContactFormApi(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ContactFormApi _api;
  final TokenStorage _tokenStorage;

  Future<List<ContactFormCategoryDto>> getCategories() {
    return _api.getCategories();
  }

  Future<void> createSubmission({
    required String idContactFormCategory,
    required String name,
    required String email,
    required String message,
  }) async {
    final token = await _tokenStorage.loadToken();
    await _api.createSubmission(
      token: token,
      input: CreateContactFormSubmissionInput(
        idContactFormCategory: idContactFormCategory.trim(),
        name: name.trim(),
        email: email.trim(),
        message: message.trim(),
      ),
    );
  }
}
