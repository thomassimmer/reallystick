import 'package:equatable/equatable.dart';
import 'package:reallystick/features/auth/domain/entities/two_factor_authentication_config.dart';

class TwoFactorAuthenticationConfigDataModel extends Equatable {
  final String otpBase32;
  final String otpAuthUrl;

  const TwoFactorAuthenticationConfigDataModel({
    required this.otpBase32,
    required this.otpAuthUrl,
  });

  // Factory constructor to create a TwoFactorAuthenticationConfigModel from JSON data
  factory TwoFactorAuthenticationConfigDataModel.fromJson(
      Map<String, dynamic> json) {
    return TwoFactorAuthenticationConfigDataModel(
      otpBase32: json['otp_base32'] as String,
      otpAuthUrl: json['otp_auth_url'] as String,
    );
  }

  TwoFactorAuthenticationConfig toDomain() => TwoFactorAuthenticationConfig(
      otpAuthUrl: otpAuthUrl, otpBase32: otpBase32);

  @override
  List<Object?> get props => [
        otpBase32,
        otpAuthUrl,
      ];
}
