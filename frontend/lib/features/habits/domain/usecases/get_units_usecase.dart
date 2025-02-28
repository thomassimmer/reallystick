import 'package:dartz/dartz.dart' hide Unit;
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/habits/domain/entities/unit.dart';
import 'package:reallystick/features/habits/domain/repositories/unit_repository.dart';

class GetUnitsUsecase {
  final UnitRepository unitRepository;

  GetUnitsUsecase(this.unitRepository);

  Future<Either<DomainError, List<Unit>>> call() async {
    return await unitRepository.getUnits();
  }
}
