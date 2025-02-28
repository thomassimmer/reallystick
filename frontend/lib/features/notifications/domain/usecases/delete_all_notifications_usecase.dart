import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/notifications/domain/repositories/notification_repository.dart';

class DeleteAllNotificationsUsecase {
  final NotificationRepository notificationRepository;

  DeleteAllNotificationsUsecase(this.notificationRepository);

  Future<Either<DomainError, void>> call() async {
    return await notificationRepository.deleteAllNotifications();
  }
}
