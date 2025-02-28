class SaveRecoveryCodeRequestModel {
  final String recoveryCode;
  final String privateKeyEncrypted;
  final String saltUsedToDeriveKeyFromRecoveryCode;

  const SaveRecoveryCodeRequestModel({
    required this.recoveryCode,
    required this.privateKeyEncrypted,
    required this.saltUsedToDeriveKeyFromRecoveryCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'recovery_code': recoveryCode,
      'private_key_encrypted': privateKeyEncrypted,
      'salt_used_to_derive_key_from_recovery_code':
          saltUsedToDeriveKeyFromRecoveryCode,
    };
  }
}
