import 'package:formz/formz.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';

class Password extends FormzInput<String, Exception> {
  const Password.pure() : super.pure('');

  const Password.dirty([super.value = '']) : super.dirty();

  @override
  Exception? validator(String? value) {
    if (value == null || value.length < 8) {
      return PasswordTooShortError();
    }

    // Matches Unicode letters
    bool hasLetter = RegExp(r'\p{L}', unicode: true).hasMatch(value);

    // Matches Unicode digits
    bool hasDigit = RegExp(r'\p{N}', unicode: true).hasMatch(value);

    // Matches ASCII punctuation characters
    bool hasSpecial =
        RegExp(r'''[!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]''').hasMatch(value);

    // Ensures all characters are valid (Unicode alphanumeric or ASCII punctuation)
    bool validCharacters = RegExp(
      r'''^[\p{L}\p{N}!"#$%&'()*+,\-./:;<=>?@[\\\]^_`{|}~]+$''',
      unicode: true,
    ).hasMatch(value);

    if (hasLetter && hasDigit && hasSpecial && validCharacters) {
      return null;
    }

    return PasswordNotComplexEnoughError();
  }
}
