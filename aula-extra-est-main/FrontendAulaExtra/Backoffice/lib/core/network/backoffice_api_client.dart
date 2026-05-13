import 'dart:convert';

import 'package:http/http.dart' as http;

class BackofficeApiClient {
  static Future<void> Function()? onUnauthorized;
  static bool _handlingUnauthorized = false;

  Future<dynamic> postAny(
    Uri uri, {
    Map<String, dynamic>? body,
    String? token,
    bool handleAuthErrors = true,
  }) async {
    final response = await http.post(
      uri,
      headers: _headers(token),
      body: body == null ? null : jsonEncode(body),
    );

    return _decodeAny(response, handleAuthErrors: handleAuthErrors);
  }

  Future<Map<String, dynamic>> postJson(
    Uri uri, {
    Map<String, dynamic>? body,
    String? token,
    bool handleAuthErrors = true,
  }) async {
    final response = await http.post(
      uri,
      headers: _headers(token),
      body: body == null ? null : jsonEncode(body),
    );

    return _decode(response, handleAuthErrors: handleAuthErrors);
  }

  Future<Map<String, dynamic>> putJson(
    Uri uri, {
    Map<String, dynamic>? body,
    String? token,
    bool handleAuthErrors = true,
  }) async {
    final response = await http.put(
      uri,
      headers: _headers(token),
      body: body == null ? null : jsonEncode(body),
    );

    return _decode(response, handleAuthErrors: handleAuthErrors);
  }

  Future<Map<String, dynamic>> getJson(
    Uri uri, {
    String? token,
    bool handleAuthErrors = true,
  }) async {
    final response = await http.get(uri, headers: _headers(token));
    return _decode(response, handleAuthErrors: handleAuthErrors);
  }

  Future<List<dynamic>> getJsonList(
    Uri uri, {
    String? token,
    bool handleAuthErrors = true,
  }) async {
    final response = await http.get(uri, headers: _headers(token));
    return _decodeList(response, handleAuthErrors: handleAuthErrors);
  }

  Future<List<dynamic>> getListJson(
    Uri uri, {
    String? token,
    bool handleAuthErrors = true,
  }) {
    return getJsonList(
      uri,
      token: token,
      handleAuthErrors: handleAuthErrors,
    );
  }

  Future<void> delete(
    Uri uri, {
    String? token,
    bool handleAuthErrors = true,
  }) async {
    final response = await http.delete(uri, headers: _headers(token));
    _ensureSuccess(response, handleAuthErrors: handleAuthErrors);
  }

  Future<Map<String, dynamic>> deleteJson(
    Uri uri, {
    Map<String, dynamic>? body,
    String? token,
    bool handleAuthErrors = true,
  }) async {
    final headers = _headers(token);

    late final http.Response response;
    if (body == null) {
      response = await http.delete(uri, headers: headers);
    } else {
      final request = http.Request('DELETE', uri)
        ..headers.addAll(headers)
        ..body = jsonEncode(body);
      final streamed = await request.send();
      response = await http.Response.fromStream(streamed);
    }

    return _decode(response, handleAuthErrors: handleAuthErrors);
  }

  Map<String, String> _headers(String? token) {
    return <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'token': token,
    };
  }

  Map<String, dynamic> _decode(
    http.Response response, {
    required bool handleAuthErrors,
  }) {
    _ensureSuccess(response, handleAuthErrors: handleAuthErrors);

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    return jsonDecode(response.body);
  }

  dynamic _decodeAny(
    http.Response response, {
    required bool handleAuthErrors,
  }) {
    _ensureSuccess(response, handleAuthErrors: handleAuthErrors);

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  List<dynamic> _decodeList(
    http.Response response, {
    required bool handleAuthErrors,
  }) {
    _ensureSuccess(response, handleAuthErrors: handleAuthErrors);

    if (response.body.isEmpty) {
      return <dynamic>[];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }

    throw const FormatException('A resposta da API não é uma lista JSON válida.');
  }

  void _ensureSuccess(
    http.Response response, {
    required bool handleAuthErrors,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    _maybeHandleUnauthorized(response.statusCode, handleAuthErrors);
    final message = response.body.isEmpty ? 'HTTP ${response.statusCode}' : response.body;
    throw Exception(message);
  }

  void _maybeHandleUnauthorized(int statusCode, bool handleAuthErrors) {
    if (!handleAuthErrors || (statusCode != 401 && statusCode != 403)) {
      return;
    }

    final callback = onUnauthorized;
    if (callback == null || _handlingUnauthorized) {
      return;
    }

    _handlingUnauthorized = true;
    callback().whenComplete(() => _handlingUnauthorized = false);
  }
}