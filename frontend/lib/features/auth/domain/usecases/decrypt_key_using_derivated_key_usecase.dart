import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:encrypt/encrypt.dart';

class DecryptKeyUsingDerivatedKeyUsecase {
  /// Decrypts an encrypted private key using the provided derived key.
  /// [encryptedData] is the JSON string containing the IV and encrypted private key.
  RSAPrivateKey call({
    required String encryptedData,
    required String derivedKey,
  }) {
    // Parse the JSON string to extract the IV and encrypted private key
    final Map<String, dynamic> encryptedJson = jsonDecode(encryptedData);
    final ivBytes = base64.decode(encryptedJson['iv']);
    final encryptedKeyBytes = base64.decode(encryptedJson['encryptedKey']);

    // Convert the derived key into bytes
    final derivedKeyBytes = base64.decode(derivedKey);

    // Ensure the derived key is 32 bytes long (AES-256 requirement)
    if (derivedKeyBytes.length != 32) {
      throw ArgumentError(
          "The derived key must be 32 bytes for AES-256 decryption.");
    }

    // Create the AES decrypter
    final encrypter = Encrypter(AES(Key(derivedKeyBytes), mode: AESMode.cbc));

    // Decrypt the private key
    final decrypted = encrypter.decrypt(
      Encrypted(encryptedKeyBytes),
      iv: IV(ivBytes),
    );

    final privateKey = CryptoUtils.rsaPrivateKeyFromPem(decrypted);

    return privateKey;
  }
}
