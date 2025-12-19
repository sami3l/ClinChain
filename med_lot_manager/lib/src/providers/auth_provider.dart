import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  User? _user;
  bool _loading = false;
  String? _error;

  AuthProvider({required this.authRepository});

  bool get isAuthenticated => _user != null;
  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final data = await authRepository.login(username, password);
    _loading = false;
    if (data == null) {
      _error = 'Invalid credentials or server error';
      notifyListeners();
      return false;
    }
    // parse user from returned payload
    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson != null) {
      _user = User.fromJson(userJson);
      notifyListeners();
      return true;
    }
    // if remote API returns token and requires /auth/me call:
    final maybeUser = await authRepository.getCurrentUser();
    if (maybeUser != null) {
      _user = maybeUser;
      notifyListeners();
      return true;
    }

    _error = 'Failed to load user profile';
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await authRepository.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }
}
