import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';

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

  const UsersLoaded({
    super.message,
    required this.users,
  });

  @override
  List<Object?> get props => [
        message,
        users,
      ];
}
