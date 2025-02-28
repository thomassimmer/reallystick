import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/users/domain/entities/user_public_data.dart';
import 'package:reallystick/features/users/domain/repositories/user_public_data_repository.dart';

class GetUsersPublicDataByUsernameUsecase {
  final UserPublicDataRepository userPublicDataRepository;

  GetUsersPublicDataByUsernameUsecase(this.userPublicDataRepository);

  Future<Either<DomainError, UserPublicData?>> call({
    required String username,
  }) async {
    return await userPublicDataRepository.getUserPublicDataByUsername(
      username: username,
    );
  }
}
