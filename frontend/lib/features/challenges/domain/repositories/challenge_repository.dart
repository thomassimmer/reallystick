// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge.dart';

abstract class ChallengeRepository {
  Future<Either<DomainError, Challenge>> getChallenge({
    required String challengeId,
  });
  Future<Either<DomainError, List<Challenge>>> getChallenges();
  Future<Either<DomainError, Challenge>> createChallenge({
    required Map<String, String> name,
    required Map<String, String> description,
    required String icon,
    required DateTime? startDate,
    required DateTime? endDate,
  });
  Future<Either<DomainError, Challenge>> updateChallenge({
    required String challengeId,
    required Map<String, String> name,
    required Map<String, String> description,
    required String icon,
    required DateTime? startDate,
    required DateTime? endDate,
  });
  Future<Either<DomainError, void>> deleteChallenge({
    required String challengeId,
  });
}
