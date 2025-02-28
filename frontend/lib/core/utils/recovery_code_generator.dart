import 'dart:math';

class RecoveryCodeGenerator {
  static const _allowedChars =
      'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Excludes easily-confused chars like 0, O, I, 1

  /// Generates a secure recovery code with [length] characters.
  static String generate({int length = 16}) {
    final random = Random.secure();
    return List.generate(
            length, (_) => _allowedChars[random.nextInt(_allowedChars.length)])
        .join();
  }
}
