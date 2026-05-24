import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/app_navigator.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _auth = AuthService();
  late final ApiClient api;

  bool isAuthenticated = false;

  AuthProvider() {
    // Prefer API_BASE_URL from --dart-define if provided; otherwise pick sensible
    // defaults for web/desktop/emulator.
    const envBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    final base = envBase.isNotEmpty
        ? envBase
        : (kIsWeb
            ? 'http://localhost:8080'
            : (Platform.isWindows || Platform.isLinux || Platform.isMacOS ? 'http://localhost:8080' : 'http://10.0.2.2:8080'));
    api = ApiClient(baseUrl: base);
  }

  Future<bool> tryAutoLogin() async {
    final t = await _auth.getToken();
    isAuthenticated = t != null;
    notifyListeners();
    return isAuthenticated;
  }

  Future<void> logout() async {
    await _auth.deleteToken();
    isAuthenticated = false;
    notifyListeners();
    try {
      appNavigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (r) => false);
    } catch (_) {}
  }

  Future<String?> login(String email, String password) async {
    try {
      final resp = await api.post('/api/auth/login', {'email': email, 'password': password});
      if (resp.statusCode == 200) {
        final data = resp.data;
        String? token;
        if (data is Map<String, dynamic>) {
          token = _auth.extractTokenFromMap(data);
        } else if (data is String) {
          // sometimes Dio returns plain string; try to parse
          try {
            final parsed = json.decode(data) as Map<String, dynamic>;
            token = _auth.extractTokenFromMap(parsed);
          } catch (_) {}
        }
        if (token != null) {
          await _auth.saveToken(token);
          isAuthenticated = true;
          notifyListeners();
          return token;
        }
      }
    } on DioException {
      rethrow;
    }
    return null;
  }
}
