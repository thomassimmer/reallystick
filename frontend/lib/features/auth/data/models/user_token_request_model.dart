class RefreshUserTokenRequestModel {
  final String refreshToken;

  const RefreshUserTokenRequestModel({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }
}

class RegisterUserRequestModel {
  final String username;
  final String password;
  final String locale;
  final String theme;
  final String publicKey;
  final String privateKeyEncrypted;
  final String saltUsedToDeriveKeyFromPassword;

  const RegisterUserRequestModel({
    required this.username,
    required this.password,
    required this.locale,
    required this.theme,
    required this.publicKey,
    required this.privateKeyEncrypted,
    required this.saltUsedToDeriveKeyFromPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'locale': locale,
      'theme': theme,
      'public_key': publicKey,
      'private_key_encrypted': privateKeyEncrypted,
      'salt_used_to_derive_key_from_password': saltUsedToDeriveKeyFromPassword,
    };
  }
}

class LoginUserRequestModel {
  final String username;
  final String password;

  const LoginUserRequestModel({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}
