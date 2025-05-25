import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/web.dart';

class TokenStorage {
  final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final logger = Logger();

  Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      await _storage.write(key: 'accessToken', value: accessToken);
      await _storage.write(key: 'refreshToken', value: refreshToken);
    } catch (e) {
      logger.e("saveTokens: $e");
      return;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: 'accessToken');
    } catch (e) {
      logger.e("getAccessToken: $e");
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: 'refreshToken');
    } catch (e) {
      logger.e("getRefreshToken: $e");
      return null;
    }
  }

  Future<void> deleteTokens() async {
    try {
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
    } catch (e) {
      logger.e("deleteTokens: $e");
      return;
    }
  }
}
