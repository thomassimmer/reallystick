import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class GetUserPublicDataEvent extends UserEvent {
  final List<String> userIds;

  const GetUserPublicDataEvent({
    required this.userIds,
  });

  @override
  List<Object?> get props => [userIds];
}
