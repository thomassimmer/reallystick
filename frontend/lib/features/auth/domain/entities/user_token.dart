class UserToken {
  final String accessToken;
  final String refreshToken;
  final String? publicKey;
  final String? privateKeyEncrypted;
  final String? saltUsedToDeriveKey;

  const UserToken({
    required this.accessToken,
    required this.refreshToken,
    required this.publicKey,
    required this.privateKeyEncrypted,
    required this.saltUsedToDeriveKey,
  });
}
