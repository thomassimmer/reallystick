import 'dart:convert';

import 'package:encrypt/encrypt.dart';

class EncryptKeyUsingDerivatedKeyUsecase {
  /// Encrypts [privateKey] using the provided [derivedKey].
  /// The output is a base64-encoded string of the encrypted private key.
  String call({
    required String privateKey,
    required String derivedKey,
  }) {
    // Convert the derived key into bytes
    final derivedKeyBytes = base64.decode(derivedKey);

    // Ensure the derived key is 32 bytes long (AES-256 requirement)
    if (derivedKeyBytes.length != 32) {
      throw ArgumentError(
          "The derived key must be 32 bytes for AES-256 encryption.");
    }

    // Generate a random IV (Initialization Vector) for AES
    final iv = IV.fromLength(16);

    // Create the AES encrypter
    final encrypter = Encrypter(AES(Key(derivedKeyBytes), mode: AESMode.cbc));

    // Encrypt the private key
    final encrypted = encrypter.encrypt(privateKey, iv: iv);

    // Return the encrypted data and IV as a single base64-encoded string
    return jsonEncode({
      'iv': base64.encode(iv.bytes),
      'encryptedKey': encrypted.base64,
    });
  }
}
