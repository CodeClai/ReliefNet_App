import 'package:disasteraid_pk/core/services/socket_service.dart'; // FIXED TYPO
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_client.dart';
import 'package:dio/dio.dart';

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
    if (_token != null) {
      try {
        final res = await _api.dio.get('/auth/me');
        _user = res.data; // REMOVED ['data']
        _api.setCurrentUser(_user!);
        _isAuthenticated = true;
      } on DioException catch (e) {
        await _storage.delete(key: 'token');
        _api.clearCurrentUser();
        _isAuthenticated = false;
        _user = null;
      }
    }
    notifyListeners();
  }

  Future<void> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    required String role,
  }) async {
    try {
      final res = await _api.dio.post('/auth/register', data: {
        'name': name,
        'email': email?.isEmpty == true ? null : email,
        'phone': phone?.isEmpty == true ? null : phone,
        'password': password,
        'role': role,
      });

      final data = res.data; // Already unwrapped
      _token = data['token'];
      _user = data['user'];
      _isAuthenticated = true;
      _api.setCurrentUser(_user!);
      await _storage.write(key: 'token', value: _token);
      notifyListeners();
    } on DioException catch (e) {
      final apiErr = e.error as ApiException?;
      if (e.response?.statusCode == 409) {
        throw apiErr?.message ?? 'Email or phone already exists';
      }
      throw apiErr?.message ?? 'Registration failed';
    }
  }

  Future<void> login(String emailOrPhone, String password) async {
    try {
      final res = await _api.dio.post('/auth/login', data: {
        'email': emailOrPhone, 
        'password': password
      });
      
      final data = res.data; // Already unwrapped
      _token = data['token'];
      _user = data['user'];
      _isAuthenticated = true;
      _api.setCurrentUser(_user!);
      await _storage.write(key: 'token', value: _token);
      notifyListeners();
    } on DioException catch (e) {
      final apiErr = e.error as ApiException?;
      throw apiErr?.message ?? 'Invalid credentials';
    }
  }

  Future<void> logout() async {
    SocketService().disconnect();
    await _storage.delete(key: 'token');
    _api.clearCurrentUser();
    _isAuthenticated = false;
    _user = null;
    _token = null;
    notifyListeners();
  }
}