// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

import 'token_storage_store_base.dart';

class WebSessionTokenStore implements TokenStore {
  static const _tokenKey = 'auth.jwt';

  @override
  Future<void> saveToken(String token) async {
    html.window.sessionStorage[_tokenKey] = token;
  }

  @override
  Future<String?> loadToken() async {
    return html.window.sessionStorage[_tokenKey];
  }

  @override
  Future<void> clearToken() async {
    html.window.sessionStorage.remove(_tokenKey);
  }
}

TokenStore createTokenStore() => WebSessionTokenStore();
