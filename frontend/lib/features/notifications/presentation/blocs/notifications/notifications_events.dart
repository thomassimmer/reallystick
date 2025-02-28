import 'package:equatable/equatable.dart';
import 'package:reallystick/features/notifications/domain/entities/notification.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeNotificationsEvent extends NotificationEvent {}

class MarkNotificationAsSeenEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsSeenEvent({
    required this.notificationId,
  });
}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationEvent({
    required this.notificationId,
  });
}

class DeleteAllNotificationsEvent extends NotificationEvent {}

class NotificationReceivedEvent extends NotificationEvent {
  final Notification notification;

  const NotificationReceivedEvent({
    required this.notification,
  });
}

class ChangeNotificationScreenVisibilityEvent extends NotificationEvent {
  final bool show;

  const ChangeNotificationScreenVisibilityEvent({
    required this.show,
  });
}

class ChangeUserConnectionStatusEvent extends NotificationEvent {
  final bool isConnected;

  const ChangeUserConnectionStatusEvent({required this.isConnected});
}
