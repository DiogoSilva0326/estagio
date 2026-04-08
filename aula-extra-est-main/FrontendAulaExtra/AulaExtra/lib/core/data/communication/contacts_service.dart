import 'package:aula_extra/core/data/communication/contacts_api.dart';
import 'package:aula_extra/core/data/communication/dtos/contact_user_summary_dto.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';

class ContactsService {
  ContactsService({
    ContactsApi? api,
    TokenStorage? tokenStorage,
  })  : _api = api ?? ContactsApi(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ContactsApi _api;
  final TokenStorage _tokenStorage;

  Future<List<ContactUserSummaryDto>> getMyContacts() async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ContactsException('Sessão expirada');
    }
    return _api.getMyContacts(token: token);
  }

  Future<List<ContactUserSummaryDto>> addContactByUsername(String username) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ContactsException('Sessão expirada');
    }
    return _api.addContactByUsername(token: token, username: username);
  }

  Future<List<ContactUserSummaryDto>> addContactByUserId(String userId) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ContactsException('Sessão expirada');
    }
    return _api.addContactByUserId(token: token, userId: userId);
  }

  Future<List<ContactUserSummaryDto>> acceptInviteByUsername(String username) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ContactsException('Sessão expirada');
    }
    return _api.acceptInviteByUsername(token: token, username: username);
  }

  Future<List<ContactUserSummaryDto>> rejectInviteByUsername(String username) async {
    final token = await _tokenStorage.loadToken();
    if (token == null || token.trim().isEmpty) {
      throw const ContactsException('Sessão expirada');
    }
    return _api.rejectInviteByUsername(token: token, username: username);
  }
}
