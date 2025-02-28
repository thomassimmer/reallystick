import 'package:dartz/dartz.dart' hide Unit;
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/unit.dart';
import 'package:reallystick/features/habits/domain/repositories/unit_repository.dart';

class CreateUnitUsecase {
  final UnitRepository unitRepository;

  CreateUnitUsecase(this.unitRepository);

  Future<Either<DomainError, Unit>> call({
    required Map<String, String> shortName,
    required Map<String, Map<String, String>> longName,
  }) async {
    return await unitRepository.createUnit(
      shortName: shortName,
      longName: longName,
    );
  }
}
