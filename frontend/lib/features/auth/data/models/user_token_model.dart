import 'package:equatable/equatable.dart';
import 'package:reallystick/features/auth/domain/entities/user_token.dart';

class UserTokenDataModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final List<String>? recoveryCodes;

  const UserTokenDataModel({
    required this.accessToken,
    required this.refreshToken,
    this.recoveryCodes,
  });

  factory UserTokenDataModel.fromJson(Map<String, dynamic> json) {
    return UserTokenDataModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      recoveryCodes: json.containsKey('recovery_codes')
          ? List<String>.from(json['recovery_codes'] as List)
          : null,
    );
  }

  UserToken toDomain() => UserToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        recoveryCodes: recoveryCodes,
      );

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        recoveryCodes,
      ];
}
