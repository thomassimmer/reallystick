import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class GetUserPublicDataEvent extends UserEvent {
  final List<String>? userIds;
  final String? username;

  const GetUserPublicDataEvent({
    required this.userIds,
    required this.username,
  });

  @override
  List<Object?> get props => [userIds, username];
}
