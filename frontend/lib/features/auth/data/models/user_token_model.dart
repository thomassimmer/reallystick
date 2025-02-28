import 'package:equatable/equatable.dart';
import 'package:reallystick/features/auth/domain/entities/user_token.dart';

class UserTokenDataModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String? publicKey;
  final String? privateKeyEncrypted;
  final String? saltUsedToDeriveKey;

  const UserTokenDataModel({
    required this.accessToken,
    required this.refreshToken,
    required this.publicKey,
    required this.privateKeyEncrypted,
    required this.saltUsedToDeriveKey,
  });

  factory UserTokenDataModel.fromJson(Map<String, dynamic> json) {
    return UserTokenDataModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      publicKey: json['public_key'] as String?,
      privateKeyEncrypted: json['private_key_encrypted'] as String?,
      saltUsedToDeriveKey: json['salt_used_to_derive_key'] as String?,
    );
  }

  UserToken toDomain() => UserToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        publicKey: publicKey,
        privateKeyEncrypted: privateKeyEncrypted,
        saltUsedToDeriveKey: saltUsedToDeriveKey,
      );

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        publicKey,
        privateKeyEncrypted,
        saltUsedToDeriveKey,
      ];
}
