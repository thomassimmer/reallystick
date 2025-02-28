// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/challenges/domain/entities/challenge_statistic.dart';

abstract class ChallengeStatisticRepository {
  Future<Either<DomainError, List<ChallengeStatistic>>>
      getChallengeStatistics();
}
