import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/navigation/models/backoffice_user_profile.dart';
import '../config/api_config.dart';
import '../network/backoffice_api_client.dart';

class BackofficeSessionController extends ChangeNotifier {
  BackofficeSessionController._() {
    BackofficeApiClient.onUnauthorized = _handleUnauthorized;
  }

  static final BackofficeSessionController instance = BackofficeSessionController._();

  static const _tokenKey = 'backoffice.auth.token';
  static const _userKey = 'backoffice.auth.user';
  static const _rolesKey = 'backoffice.auth.roles';

  bool _initialized = false;
  bool _busy = false;
  String? _token;
  Map<String, dynamic>? _user;
  List<String> _roles = <String>[];

  bool get initialized => _initialized;
  bool get isBusy => _busy;
  bool get isAuthenticated => (_token?.isNotEmpty ?? false) && _roles.any((role) => role.toLowerCase() == 'admin');
  String? get token => _token;
  List<String> get roles => List.unmodifiable(_roles);
  String? get displayName {
    final direct = _user?['displayName']?.toString();
    if (direct != null && direct.trim().isNotEmpty) return direct.trim();

    final firstName = _user?['firstName']?.toString().trim() ?? '';
    final lastName = _user?['lastName']?.toString().trim() ?? '';
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? null : fullName;
  }

  BackofficeUserProfile? get userProfile {
    final email = _user?['email']?.toString();
    final name = displayName;
    if (email == null || email.isEmpty || name == null || name.isEmpty) {
      return null;
    }

    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
      .map((part) => part.substring(0, 1).toUpperCase())
        .join();

    return BackofficeUserProfile(
      name: name,
      email: email,
      initials: parts.isEmpty ? 'AD' : parts,
    );
  }

  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);

    final userRaw = prefs.getString(_userKey);
    if (userRaw != null && userRaw.isNotEmpty) {
      _user = jsonDecode(userRaw) as Map<String, dynamic>;
    }

    final savedRoles = prefs.getStringList(_rolesKey);
    if (savedRoles != null) {
      _roles = savedRoles;
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _busy = true;
    notifyListeners();

    try {
      final payload = await BackofficeApiClient().postJson(
        ApiConfig.uri('/api/Authentication/AdminLogin'),
        body: <String, dynamic>{
          'email': email,
          'password': password,
        },
        handleAuthErrors: false,
      );

      _token = payload['token']?.toString();
      _user = (payload['user'] as Map?)?.cast<String, dynamic>();
      _roles = ((payload['roles'] as List?) ?? const <dynamic>[])
          .map((item) => item.toString())
          .toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, _token ?? '');
      await prefs.setString(_userKey, jsonEncode(_user ?? <String, dynamic>{}));
      await prefs.setStringList(_rolesKey, _roles);
    } finally {
      _busy = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> logout({bool notifyServer = true}) async {
    final currentToken = _token;
    _token = null;
    _user = null;
    _roles = <String>[];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_rolesKey);

    if (notifyServer && currentToken != null && currentToken.isNotEmpty) {
      try {
        await BackofficeApiClient().postJson(
          ApiConfig.uri('/api/Authentication/Logout'),
          token: currentToken,
          handleAuthErrors: false,
        );
      } catch (_) {
      }
    }

    notifyListeners();
  }

  Future<void> _handleUnauthorized() async {
    if (_token == null || _token!.isEmpty) {
      return;
    }

    await logout(notifyServer: false);
  }
}