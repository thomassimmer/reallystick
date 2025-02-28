import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class DecryptMessageUsingAesUsecase {
  /// Decrypts [encryptedContent] using the provided AES key and returns the plaintext content.
  Future<String> call({
    required String encryptedContent,
    required String aesKey,
  }) async {
    // Decode the AES key and encrypted content from base64
    final aesKeyBytes = base64.decode(aesKey);
    final encryptedBytes = base64.decode(encryptedContent);

    // Extract the nonce (IV) and ciphertext from the encrypted content
    final algorithm = AesGcm.with256bits();
    final secretBox = SecretBox.fromConcatenation(
      encryptedBytes,
      nonceLength: 16, // IV length for AES-GCM
      macLength: 16, // Default MAC length
    );

    // Decrypt the content
    final secretKey = SecretKey(aesKeyBytes);
    final decryptedBytes = await algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );

    // Convert the decrypted bytes back into a string
    return utf8.decode(decryptedBytes);
  }
}
