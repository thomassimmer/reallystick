import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class EncryptMessageUsingAesUsecaseResult {
  final String encryptedContent;
  final String aesKey;

  const EncryptMessageUsingAesUsecaseResult({
    required this.encryptedContent,
    required this.aesKey,
  });
}

class EncryptMessageUsingAesUsecase {
  /// Encrypts [content] using AES encryption and returns the encrypted content
  /// and the AES key used, both base64-encoded.
  Future<EncryptMessageUsingAesUsecaseResult> call({
    required String content,
    required SecretKey? aesKey,
  }) async {
    // Generate a random AES key (256 bits)
    aesKey ??= SecretKeyData.random(length: 32);

    // Generate a random IV (Initialization Vector, 16 bytes for AES)
    final iv = Uint8List(16); // 128-bit IV
    final random = Random.secure();
    for (int i = 0; i < iv.length; i++) {
      iv[i] = random.nextInt(256);
    }

    // Encrypt the content
    final algorithm = AesGcm.with256bits();
    final secretBox = await algorithm.encrypt(
      utf8.encode(content),
      secretKey: aesKey,
      nonce: iv, // AES-GCM uses IV as "nonce"
    );

    // Extract the AES key bytes for base64 encoding
    final aesKeyBytes = await aesKey.extractBytes();

    return EncryptMessageUsingAesUsecaseResult(
      encryptedContent: base64.encode(secretBox.concatenation()),
      aesKey: base64.encode(aesKeyBytes),
    );
  }
}
