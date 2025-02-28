import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';

class DecryptSymmetricKeyWithRsaPrivateKeyUsecase {
  /// Decrypts the [encryptedAesKey] (base64-encoded) using the RSA [rsaPrivateKey] (PEM format)
  /// and returns the original AES key (base64-encoded).
  Future<String> call({
    required String encryptedAesKey,
    required String rsaPrivateKeyPem,
  }) async {
    // Decode the base64-encrypted AES key
    final encryptedAesKeyBytes = base64.decode(encryptedAesKey);

    // Load the RSA private key
    final parser = RSAKeyParser();
    final privateKey = parser.parse(rsaPrivateKeyPem) as RSAPrivateKey;

    // Decrypt the AES key with RSA
    final rsaEngine = RSAEngine()
      ..init(
        false,
        PrivateKeyParameter<RSAPrivateKey>(privateKey),
      );
    final decryptedAesKeyBytes = rsaEngine.process(
      Uint8List.fromList(encryptedAesKeyBytes),
    );

    return base64.encode(decryptedAesKeyBytes);
  }
}
