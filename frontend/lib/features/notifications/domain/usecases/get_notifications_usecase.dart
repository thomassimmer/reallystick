import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/notifications/domain/entities/notification.dart';
import 'package:reallystick/features/notifications/domain/repositories/notification_repository.dart';

class GetNotificationsUsecase {
  final NotificationRepository notificationRepository;

  GetNotificationsUsecase(this.notificationRepository);

  Future<Either<DomainError, List<Notification>>> call() async {
    return await notificationRepository.getNotifications();
  }
}
