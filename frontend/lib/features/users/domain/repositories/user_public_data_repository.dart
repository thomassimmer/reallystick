// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';

abstract class UserPublicDataRepository {
  Future<Either<DomainError, List<UserPublicData>>> getUserPublicData({
    required List<String> userIds,
  });
}
