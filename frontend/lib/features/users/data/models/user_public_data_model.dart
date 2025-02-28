import 'package:equatable/equatable.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';

class UserPublicDataModel extends Equatable {
  final String id;
  final String username;

  const UserPublicDataModel({
    required this.id,
    required this.username,
  });

  factory UserPublicDataModel.fromJson(Map<String, dynamic> json) {
    return UserPublicDataModel(
      id: json['id'] as String,
      username: json['username'] as String,
    );
  }

  UserPublicData toDomain() => UserPublicData(id: id, username: username);

  @override
  List<Object?> get props => [
        id,
        username,
      ];
}
