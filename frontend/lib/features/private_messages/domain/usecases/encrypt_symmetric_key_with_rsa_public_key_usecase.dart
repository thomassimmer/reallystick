import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart';

class EncryptSymmetricKeyWithRsaPublicKeyUsecase {
  /// Encrypts the [aesKey] (base64-encoded) using the RSA [rsaPublicKey] (PEM format)
  /// and returns the RSA-encrypted AES key (base64-encoded).
  Future<String> call({
    required String aesKey,
    required String rsaPublicKeyPem,
  }) async {
    // Decode the base64 AES key
    final aesKeyBytes = base64.decode(aesKey);

    // Load the RSA public key
    final parser = RSAKeyParser();
    final publicKey = parser.parse(rsaPublicKeyPem) as RSAPublicKey;

    // Encrypt the AES key with RSA
    final rsaEngine = RSAEngine()
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    final encryptedAesKeyBytes =
        rsaEngine.process(Uint8List.fromList(aesKeyBytes));

    return base64.encode(encryptedAesKeyBytes);
  }
}
