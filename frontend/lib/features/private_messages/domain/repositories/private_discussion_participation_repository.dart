// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';

abstract class PrivateDiscussionParticipationRepository {
  Future<Either<DomainError, void>> updatePrivateDiscussionParticipation({
    required String discussionId,
    required String color,
    required bool hasBlocked,
  });
}
