import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _api = ApiClient();

  bool _isAuthenticated = false;
  Map<String, dynamic>? _user;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get user => _user;

  Future<void> checkAuth() async {
    _token = await _storage.read(key: 'token');
    _isAuthenticated = _token!= null;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    required String role,
  }) async {
    final res = await _api.dio.post('/auth/register', data: {
      'name': name, 'email': email, 'phone': phone, 'password': password, 'role': role,
    });
    _token = res.data['data']['token'];
    _user = res.data['data']['user'];
    _isAuthenticated = true;
    await _storage.write(key: 'token', value: _token);
    notifyListeners();
  }

  Future<void> login(String emailOrPhone, String password) async {
    final res = await _api.dio.post('/auth/login', data: {'email': emailOrPhone, 'password': password});
    _token = res.data['data']['token'];
    _user = res.data['data']['user'];
    _isAuthenticated = true;
    await _storage.write(key: 'token', value: _token);
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    _isAuthenticated = false;
    _user = null;
    _token = null;
    notifyListeners();
  }
}
