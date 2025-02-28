import 'package:formz/formz.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';

class Username extends FormzInput<String, Exception> {
  const Username.pure() : super.pure('');

  const Username.dirty([super.value = '']) : super.dirty();

  @override
  Exception? validator(String? value) {
    final RegExp pattern =
        RegExp(r'^[\p{L}\p{N}_]([._-]?[\p{L}\p{N}_]+)*$', unicode: true);
    // Length check (example: min 3, max 20)
    if (value!.length < 3 || value.length > 20) {
      return UsernameWrongSizeError();
    }
    // Regex pattern check
    if (pattern.hasMatch(value)) {
      return null;
    }

    return UsernameNotRespectingRulesError();
  }
}
