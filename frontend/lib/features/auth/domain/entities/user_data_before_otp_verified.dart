class UserDataBeforeOtpVerified {
  final String userId;
  final String? publicKey;
  final String? privateKeyEncrypted;
  final String? saltUsedToDeriveKey;

  const UserDataBeforeOtpVerified({
    required this.userId,
    required this.publicKey,
    required this.privateKeyEncrypted,
    required this.saltUsedToDeriveKey,
  });
}
