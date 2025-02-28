import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';
import 'package:reallystick/features/users/domain/repositories/user_public_data_repository.dart';

class GetUsersPublicDataByIdUsecase {
  final UserPublicDataRepository userPublicDataRepository;

  GetUsersPublicDataByIdUsecase(this.userPublicDataRepository);

  Future<Either<DomainError, List<UserPublicData>>> call({
    required List<String> userIds,
  }) async {
    return await userPublicDataRepository.getUserPublicDataById(
      userIds: userIds,
    );
  }
}
