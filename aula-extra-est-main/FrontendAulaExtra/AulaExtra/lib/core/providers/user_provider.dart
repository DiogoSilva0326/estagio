import 'package:flutter/foundation.dart';

enum Role {
  none,
  student,
  teacher,
  tutor,
  psychologist,
}

class UserAccount {
  const UserAccount({
    this.fullName,
    this.email,
    this.username,
    this.mobileNumber,
    this.nif,
    this.profileImageUrl,
    this.creditsBalance,
    this.creditsCurrency,
  });

  final String? fullName;
  final String? email;
  final String? username;
  final String? mobileNumber;
  final String? nif;
  final String? profileImageUrl;
  final double? creditsBalance;
  final String? creditsCurrency;

  UserAccount copyWith({
    String? fullName,
    String? email,
    String? username,
    String? mobileNumber,
    String? nif,
    String? profileImageUrl,
    double? creditsBalance,
    String? creditsCurrency,
  }) {
    return UserAccount(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      username: username ?? this.username,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      nif: nif ?? this.nif,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      creditsBalance: creditsBalance ?? this.creditsBalance,
      creditsCurrency: creditsCurrency ?? this.creditsCurrency,
    );
  }
}

class UserProvider extends ChangeNotifier {
  bool get isTeachingRole => _role == Role.teacher || _role == Role.tutor || _role == Role.psychologist;
  bool get isStudentRole => _role == Role.student;

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
    print('DEBUG: Role a mudar de $_role para $role');
    _role = role;
    notifyListeners();
  }
}
