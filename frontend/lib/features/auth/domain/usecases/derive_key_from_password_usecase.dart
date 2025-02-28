import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class DeriveKeyFromPasswordUsecaseResult {
  final String derivedKey;
  final String salt;

  const DeriveKeyFromPasswordUsecaseResult({
    required this.derivedKey,
    required this.salt,
  });
}

class DeriveKeyFromPasswordUsecase {
  Future<DeriveKeyFromPasswordUsecaseResult> call({
    required String password,
    required List<int>? salt,
  }) async {
    salt ??= _generateSalt();

    final algorithm = Argon2id(
      parallelism: 2,
      memory: 32768,
      iterations: 2,
      hashLength: 32,
    );

    final secretKey = await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );

    final derivedKeyBytes = await secretKey.extractBytes();

    return DeriveKeyFromPasswordUsecaseResult(
      derivedKey: base64Encode(derivedKeyBytes),
      salt: base64Encode(salt),
    );
  }

  List<int> _generateSalt() {
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }
}
