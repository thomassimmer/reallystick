import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/notifications/domain/repositories/notification_repository.dart';

class SaveFcmTokenUsecase {
  final NotificationRepository notificationRepository;

  SaveFcmTokenUsecase(this.notificationRepository);

  Future<Either<DomainError, void>> call({
    required String fcmToken,
  }) async {
    return await notificationRepository.saveFcmToken(
      fcmToken: fcmToken,
    );
  }
}
