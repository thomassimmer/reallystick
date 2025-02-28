import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/notifications/domain/repositories/notification_repository.dart';

class DeleteNotificationUsecase {
  final NotificationRepository notificationRepository;

  DeleteNotificationUsecase(this.notificationRepository);

  Future<Either<DomainError, void>> call({
    required String notificationId,
  }) async {
    return await notificationRepository.deleteNotification(
      notificationId: notificationId,
    );
  }
}
