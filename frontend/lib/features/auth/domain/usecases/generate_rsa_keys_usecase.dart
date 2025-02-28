import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/pointycastle.dart';

class GenerateRSAKeysUsecase {
  AsymmetricKeyPair<PublicKey, PrivateKey> call() {
    final keyParams =
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 1024, 12);
    final rng = SecureRandom('Fortuna')
      ..seed(
        KeyParameter(
          Uint8List.fromList(
            List.generate(
              32,
              (i) => Random.secure().nextInt(256),
            ),
          ),
        ),
      );
    final keyGen = RSAKeyGenerator();

    keyGen.init(
      ParametersWithRandom(keyParams, rng),
    );

    final keyPair = keyGen.generateKeyPair();
    return keyPair;
  }
}
