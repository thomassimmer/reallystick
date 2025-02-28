// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';

abstract class PublicMessageLikeRepository {
  Future<Either<DomainError, void>> createPublicMessageLike({
    required String messageId,
  });
  Future<Either<DomainError, void>> deletePublicMessageLike({
    required String messageId,
  });
}
