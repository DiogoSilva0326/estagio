import 'package:flutter/foundation.dart';

enum Role {
  none,
  student,
  teacher,
}

class UserAccount {
  const UserAccount({
    this.fullName,
    this.email,
    this.username,
    this.mobileNumber,
    this.nif,
  });

  final String? fullName;
  final String? email;
  final String? username;
  final String? mobileNumber;
  final String? nif;

  UserAccount copyWith({
    String? fullName,
    String? email,
    String? username,
    String? mobileNumber,
    String? nif,
  }) {
    return UserAccount(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      nif: nif ?? this.nif,
    );
  }
}

class UserProvider extends ChangeNotifier {
  Role _role = Role.none;
  UserAccount? _account;

  Role get role => _role;

  UserAccount? get account => _account;

  bool get isLoggedIn => _role != Role.none;

  void setAccount(UserAccount? account) {
    _account = account;
    notifyListeners();
  }

  void setRole(Role role) {
    if (_role == role) return;
    _role = role;
    notifyListeners();
  }
}
