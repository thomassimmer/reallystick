import 'package:equatable/equatable.dart';
import 'package:reallystick/features/auth/domain/entities/user_data_before_otp_verified.dart';

class UserDataBeforeOtpVerifiedModel extends Equatable {
  final String userId;
  final String? publicKey;
  final String? privateKeyEncrypted;
  final String? saltUsedToDeriveKey;

  const UserDataBeforeOtpVerifiedModel({
    required this.userId,
    required this.publicKey,
    required this.privateKeyEncrypted,
    required this.saltUsedToDeriveKey,
  });

  factory UserDataBeforeOtpVerifiedModel.fromJson(Map<String, dynamic> json) {
    return UserDataBeforeOtpVerifiedModel(
      userId: json['user_id'] as String,
      publicKey: json['public_key'] as String?,
      privateKeyEncrypted: json['private_key_encrypted'] as String?,
      saltUsedToDeriveKey: json['salt_used_to_derive_key'] as String?,
    );
  }

  UserDataBeforeOtpVerified toDomain() => UserDataBeforeOtpVerified(
        userId: userId,
        publicKey: publicKey,
        privateKeyEncrypted: privateKeyEncrypted,
        saltUsedToDeriveKey: saltUsedToDeriveKey,
      );

  @override
  List<Object?> get props => [
        userId,
        publicKey,
        privateKeyEncrypted,
        saltUsedToDeriveKey,
      ];
}
