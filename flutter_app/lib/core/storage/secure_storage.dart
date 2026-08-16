import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _tenantIdKey = 'tenant_id';
  static const _roleKey = 'role';
  static const _nameKey = 'name';
  static const _emailKey = 'email';

  // Access Token
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  // Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  // User data
  static Future<void> saveUserData({
    required String userId,
    required String tenantId,
    required String role,
    required String name,
    required String email,
  }) async {
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _tenantIdKey, value: tenantId);
    await _storage.write(key: _roleKey, value: role);
    await _storage.write(key: _nameKey, value: name);
    await _storage.write(key: _emailKey, value: email);
  }

  static Future<Map<String, String?>> getUserData() async {
    return {
      'userId': await _storage.read(key: _userIdKey),
      'tenantId': await _storage.read(key: _tenantIdKey),
      'role': await _storage.read(key: _roleKey),
      'name': await _storage.read(key: _nameKey),
      'email': await _storage.read(key: _emailKey),
    };
  }

  // Clear semua data saat logout
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}