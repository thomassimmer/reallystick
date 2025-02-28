import 'package:equatable/equatable.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileInitializeEvent extends ProfileEvent {}

class ProfileLogoutEvent extends ProfileEvent {}

class ProfileUpdateEvent extends ProfileEvent {
  final Profile newProfile;
  final bool displayNotification;

  ProfileUpdateEvent(
      {required this.newProfile, this.displayNotification = true});

  @override
  List<Object?> get props => [newProfile, displayNotification];
}

class ProfileGenerateTwoFactorAuthenticationConfigEvent extends ProfileEvent {}

class ProfileDisableTwoFactorAuthenticationEvent extends ProfileEvent {}

class ProfileVerifyOneTimePasswordEvent extends ProfileEvent {
  final String code;

  const ProfileVerifyOneTimePasswordEvent({
    required this.code,
  });

  @override
  List<Object> get props => [code];
}

class ProfileSetPasswordEvent extends ProfileEvent {
  final String newPassword;

  const ProfileSetPasswordEvent({required this.newPassword});

  @override
  List<Object> get props => [newPassword];
}

class ProfileUpdatePasswordEvent extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ProfileUpdatePasswordEvent(
      {required this.currentPassword, required this.newPassword});

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class DeleteAccountEvent extends ProfileEvent {}

class DeleteDeviceEvent extends ProfileEvent {
  final String deviceId;

  const DeleteDeviceEvent({
    required this.deviceId,
  });

  @override
  List<Object> get props => [
        deviceId,
      ];
}
