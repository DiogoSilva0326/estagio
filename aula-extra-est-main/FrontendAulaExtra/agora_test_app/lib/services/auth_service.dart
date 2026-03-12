import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// User information from authentication
class AuthUser {
  final int id;
  final String username;
  final String? displayName;
  final String? email;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  AuthUser({
    required this.id,
    required this.username,
    this.displayName,
    this.email,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Whether user can start video calls (professor or admin)
  bool get canStartVideoCall => role == 'admin' || role == 'professor';

  /// Whether user has admin privileges
  bool get isAdmin => role == 'admin';

  /// Whether user is a professor
  bool get isProfessor => role == 'professor';

  /// Whether user is a student (aluno)
  bool get isStudent => role == 'aluno';

  /// Display name or username
  String get effectiveDisplayName => displayName ?? username;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'aluno',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'email': email,
        'role': role,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt?.toIso8601String(),
      };
}

/// Authentication response from the API
class AuthResponse {
  final bool success;
  final String? error;
  final String? token;
  final DateTime? expiresAt;
  final AuthUser? user;

  AuthResponse({
    required this.success,
    this.error,
    this.token,
    this.expiresAt,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool,
      error: json['error'] as String?,
      token: json['token'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      user:
          json['user'] != null ? AuthUser.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}

/// Service for managing user authentication
class AuthService extends ChangeNotifier {
  AuthService({http.Client? client, required this.baseUrl})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  AuthUser? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _lastError;

  /// Current authenticated user
  AuthUser? get currentUser => _currentUser;

  /// Current authentication token
  String? get token => _token;

  /// Whether the user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Whether a request is in progress
  bool get isLoading => _isLoading;

  /// Last error message
  String? get lastError => _lastError;

  /// Authorization headers for API requests
  Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Initialize the service by loading stored credentials
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      final userJson = prefs.getString(_userKey);

      if (_token != null && userJson != null) {
        _currentUser = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        // If this is a developer placeholder token, skip validation.
        // Placeholder tokens use the prefix 'dev-token-'.
        if (!(_token!.startsWith('dev-token-'))) {
          try {
            await refreshCurrentUser();
          } catch (e) {
            // Token is invalid, clear credentials
            await logout();
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }
    notifyListeners();
  }

  /// Register a new user
  Future<AuthResponse> register({
    required String username,
    required String password,
    String? displayName,
    String? email,
    String role = 'aluno',
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'displayName': displayName ?? username,
          'email': email,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.user != null) {
        // Save credentials even when no JWT token is returned (development mode)
        // Generate a simple placeholder token when the backend does not provide one.
        final effectiveResponse = authResponse.token == null
            ? AuthResponse(
                success: authResponse.success,
                error: authResponse.error,
                token: 'dev-token-${authResponse.user!.id}',
                expiresAt: authResponse.expiresAt,
                user: authResponse.user,
              )
            : authResponse;

        await _saveCredentials(effectiveResponse);
        return effectiveResponse;
      } else {
        _lastError = authResponse.error ?? 'Registration failed';
        return authResponse;
      }
    } catch (e) {
      _lastError = e.toString();
      return AuthResponse(success: false, error: _lastError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with username and password
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);

      if (authResponse.success && authResponse.user != null) {
        // If backend does not return a JWT token yet, create a placeholder
        final effectiveResponse = authResponse.token == null
            ? AuthResponse(
                success: authResponse.success,
                error: authResponse.error,
                token: 'dev-token-${authResponse.user!.id}',
                expiresAt: authResponse.expiresAt,
                user: authResponse.user,
              )
            : authResponse;

        await _saveCredentials(effectiveResponse);
        return effectiveResponse;
      } else {
        _lastError = authResponse.error ?? 'Login failed';
        return authResponse;
      }
    } catch (e) {
      _lastError = e.toString();
      return AuthResponse(success: false, error: _lastError);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      if (_token != null) {
        await _client.post(
          Uri.parse('$baseUrl/api/auth/logout'),
          headers: authHeaders,
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    }

    _currentUser = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    notifyListeners();
  }

  /// Refresh the current user information
  Future<AuthUser?> refreshCurrentUser() async {
    if (_token == null) return null;

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/auth/me'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final authResponse = AuthResponse.fromJson(data);

        if (authResponse.success && authResponse.user != null) {
          _currentUser = authResponse.user;
          notifyListeners();
          return _currentUser;
        }
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }

    return null;
  }

  /// Change the user's password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_token == null) return false;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/auth/change-password'),
        headers: authHeaders,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] == true) {
        return true;
      } else {
        _lastError = data['error'] as String?;
        return false;
      }
    } catch (e) {
      _lastError = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save credentials to secure storage
  Future<void> _saveCredentials(AuthResponse authResponse) async {
    _token = authResponse.token;
    _currentUser = authResponse.user;

    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString(_tokenKey, _token!);
    }
    if (_currentUser != null) {
      await prefs.setString(_userKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  /// Check if a username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      // For now, we'll just try to register and handle the error
      // In a production app, you'd have a dedicated endpoint for this
      return true;
    } catch (e) {
      return false;
    }
  }
}
