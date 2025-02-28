class SaveKeysRequestModel {
  final String publicKey;
  final String privateKeyEncrypted;
  final String saltUsedToDeriveKeyFromPassword;

  const SaveKeysRequestModel({
    required this.publicKey,
    required this.privateKeyEncrypted,
    required this.saltUsedToDeriveKeyFromPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'public_key': publicKey,
      'private_key_encrypted': privateKeyEncrypted,
      'salt_used_to_derive_key_from_password': saltUsedToDeriveKeyFromPassword,
    };
  }
}

