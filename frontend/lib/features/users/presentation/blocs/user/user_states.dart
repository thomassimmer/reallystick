import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';
import 'package:reallystick/i18n/app_localizations.dart';

abstract class UserState extends Equatable {
  final Message? message;

  const UserState({
    this.message,
  });

  @override
  List<Object?> get props => [message];
}

class UsersLoading extends UserState {
  const UsersLoading({
    super.message,
  });
}

class UsersFailed extends UserState {
  const UsersFailed({
    super.message,
  });
}

class UsersLoaded extends UserState {
  final Map<String, UserPublicData> users;
  final UserPublicData? user;

  const UsersLoaded({
    super.message,
    required this.users,
    required this.user,
  });

  @override
  List<Object?> get props => [
        message,
        users,
        user,
      ];

  String getUsername(BuildContext context, String userId) {
    return users[userId] != null
        ? users[userId]!.isDeleted
            ? AppLocalizations.of(context)!.deletedUser
            : users[userId]!.username
        : AppLocalizations.of(context)!.unknown;
  }
}
