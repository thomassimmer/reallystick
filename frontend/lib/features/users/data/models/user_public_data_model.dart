import 'package:equatable/equatable.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';

class UserPublicDataModel extends Equatable {
  final String id;
  final String username;
  final String? publicKey;
  final bool isDeleted;

  const UserPublicDataModel({
    required this.id,
    required this.username,
    required this.publicKey,
    required this.isDeleted,
  });

  factory UserPublicDataModel.fromJson(Map<String, dynamic> json) {
    return UserPublicDataModel(
      id: json['id'] as String,
      username: json['username'] as String,
      publicKey: json['public_key'] as String,
      isDeleted: json['is_deleted'] as bool,
    );
  }

  UserPublicData toDomain() => UserPublicData(
        id: id,
        username: username,
        publicKey: publicKey,
        isDeleted: isDeleted,
      );

  @override
  List<Object?> get props => [
        id,
        username,
        publicKey,
        isDeleted,
      ];
}
