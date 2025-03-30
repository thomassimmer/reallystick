import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/constants/dates.dart';
import 'package:reallystick/features/notifications/domain/entities/notification.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';

class NotificationsWidget extends StatefulWidget {
  final Notification notification;

  const NotificationsWidget({
    required this.notification,
  });

  @override
  NotificationsWidgetState createState() => NotificationsWidgetState();
}

class NotificationsWidgetState extends State<NotificationsWidget> {
  void deleteNotification({required String notificationId}) {
    BlocProvider.of<NotificationBloc>(context).add(
      DeleteNotificationEvent(notificationId: notificationId),
    );
  }

  void markNotificationAsSeen({required String notificationId}) {
    BlocProvider.of<NotificationBloc>(context).add(
      MarkNotificationAsSeenEvent(notificationId: notificationId),
    );
  }

  @override
  void initState() {
    super.initState();
    if (!widget.notification.seen) {
      markNotificationAsSeen(notificationId: widget.notification.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;
    final userLocale = profileState.profile!.locale;

    final date = widget.notification.createdAt.isSameDate(DateTime.now())
        ? DateFormat.Hm().format(widget.notification.createdAt)
        : DateFormat.yMEd(userLocale)
            .add_Hm()
            .format(widget.notification.createdAt);

    return AnimatedContainer(
      duration: Duration(seconds: 2),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: widget.notification.seen
            ? null
            : Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: widget.notification.seen
            ? []
            : [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
      ),
      child: ListTile(
        title: Text(
          widget.notification.title,
          style: TextStyle(
            fontWeight:
                widget.notification.seen ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "${widget.notification.body}\n$date",
          style: TextStyle(height: 1.5),
        ),
        isThreeLine: true,
        onTap: () {
          if (widget.notification.url != null) {
            BlocProvider.of<NotificationBloc>(context).add(
              ChangeNotificationScreenVisibilityEvent(
                show: false,
              ),
            );
            context.go(widget.notification.url!);
          }
        },
        trailing: SizedBox(
          width: 20.0,
          child: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => deleteNotification(
              notificationId: widget.notification.id,
            ),
          ),
        ),
      ),
    );
  }
}
