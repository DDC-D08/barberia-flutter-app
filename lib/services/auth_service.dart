import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _key = 'jwt_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) => _storage.write(key: _key, value: token);
  Future<String?> getToken() => _storage.read(key: _key);
  Future<void> deleteToken() => _storage.delete(key: _key);

  /// Extract token from either `{token: '...'} ` or `{ data: { token: '...' } }`
  String? extractTokenFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    if (map.containsKey('token') && map['token'] is String) return map['token'] as String;
    if (map.containsKey('data') && map['data'] is Map) {
      final data = map['data'] as Map;
      if (data.containsKey('token') && data['token'] is String) return data['token'] as String;
    }
    return null;
  }
}
