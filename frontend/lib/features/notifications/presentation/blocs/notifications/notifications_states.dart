import 'package:equatable/equatable.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/notifications/domain/entities/notification.dart';

class NotificationState extends Equatable {
  final Message? message;
  final List<Notification> notifications;
  final Notification? notification;
  final bool notificationScreenIsVisible;
  final bool isConnected;

  const NotificationState({
    this.message,
    required this.notifications,
    required this.notification,
    required this.notificationScreenIsVisible,
    required this.isConnected,
  });

  @override
  List<Object?> get props => [
        message,
        notifications,
        notification,
        notificationScreenIsVisible,
        isConnected,
      ];
}
