// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<DomainError, List<Notification>>> getNotifications();
  Future<Either<DomainError, void>> markNotificationAsSeen({
    required String notificationId,
  });
  Future<Either<DomainError, void>> saveFcmToken({
    required String fcmToken
  });
  Future<Either<DomainError, void>> deleteNotification({
    required String notificationId,
  });
  Future<Either<DomainError, void>> deleteAllNotifications();
}
