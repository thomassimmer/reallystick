import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PrivateMessageKeyStorage {
  final _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveKeys(
    String publicKey,
    String privateKey,
  ) async {
    await _storage.write(key: 'publicKey', value: publicKey);
    await _storage.write(key: 'privateKey', value: privateKey);
  }

  Future<String?> getPublicKey() async {
    return await _storage.read(key: 'publicKey');
  }

  Future<String?> getPrivateKey() async {
    return await _storage.read(key: 'privateKey');
  }

  Future<void> deleteKeys() async {
    await _storage.delete(key: 'publicKey');
    await _storage.delete(key: 'privateKey');
  }
}
