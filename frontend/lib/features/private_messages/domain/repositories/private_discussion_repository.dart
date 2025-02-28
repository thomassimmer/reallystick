// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';

abstract class PrivateDiscussionRepository {
  Future<Either<DomainError, PrivateDiscussion>> createPrivateDiscussion({
    required String recipientId,
    required String color,
  });
  Future<Either<DomainError, List<PrivateDiscussion>>> getPrivateDiscussions();
}
