// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart' hide Unit;
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/unit.dart';

abstract class UnitRepository {
  Future<Either<DomainError, List<Unit>>> getUnits();
  Future<Either<DomainError, Unit>> createUnit({
    required Map<String, String> shortName,
    required Map<String, Map<String, String>> longName,
  });
  Future<Either<DomainError, Unit>> updateUnit({
    required String unitId,
    required Map<String, String> shortName,
    required Map<String, Map<String, String>> longName,
  });
}
