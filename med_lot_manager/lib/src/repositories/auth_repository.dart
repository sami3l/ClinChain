import 'package:uuid/uuid.dart';
import '../config/config.dart';
import '../services/api_service.dart';
import '../models/user.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>?> login(String username, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();

  static AuthRepository create(
      {required Config config, required ApiService apiService}) {
    if (config.useMock) {
      return MockAuthRepository(apiService: apiService);
    } else {
      return RemoteAuthRepository(apiService: apiService);
    }
  }
}

/// Mock implementation (for local use). Stores token in ApiService storage and returns sample users.
class MockAuthRepository implements AuthRepository {
  final ApiService apiService;
  final _uuid = Uuid();
  MockAuthRepository({required this.apiService});

  final Map<String, User> _users = {
    'grossiste': User(id: 'u1', username: 'grossiste', role: Role.grossiste),
    'hopitale': User(id: 'u2', username: 'hopitale', role: Role.hopitale),
    'pharmacien': User(id: 'u3', username: 'pharmacien', role: Role.pharmacien),
    'infirmier': User(id: 'u4', username: 'infirmier', role: Role.infirmier),
  };

  @override
  Future<Map<String, dynamic>?> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (password != 'password' || !_users.containsKey(username)) return null;
    final token = _uuid.v4();
    await apiService.storeToken(token);
    final user = _users[username]!;
    return {'token': token, 'user': user.toJson()};
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await apiService.getToken();
    if (token == null) return null;
    // For mock: there's no server token mapping; we'll just return a default user.
    // But to keep behavior consistent, we'll store last-logged-in user in memory by parsing token - not ideal.
    // For simplicity, return null here so app re-auths on restart (or we can store last user separately).
    return null;
  }

  @override
  Future<void> logout() async {
    await apiService.clearToken();
  }
}

/// Remote implementation (calls real backend). Replace endpoints to match your backend API.
class RemoteAuthRepository implements AuthRepository {
  final ApiService apiService;
  RemoteAuthRepository({required this.apiService});

  @override
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final resp = await apiService
          .post('/auth/login', {'username': username, 'password': password});
      final data = resp.data as Map<String, dynamic>;
      final token = data['token'] as String;
      await apiService.storeToken(token);
      return data;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await apiService.clearToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final resp = await apiService.get('/auth/me');
      final data = resp.data as Map<String, dynamic>;
      return User.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
