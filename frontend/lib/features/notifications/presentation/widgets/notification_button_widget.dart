import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_events.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_states.dart';

class NotificationButtonWidget extends StatefulWidget {
  final bool previewMode;

  const NotificationButtonWidget({
    required this.previewMode,
  });

  @override
  NotificationButtonWidgetState createState() =>
      NotificationButtonWidgetState();
}

class NotificationButtonWidgetState extends State<NotificationButtonWidget> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, notificationState) {
        if (widget.previewMode) {
          notificationState = getNotificationStateForPreview(context);
        }

        final unseenNotifications =
            notificationState.notifications.where((n) => !n.seen).length;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: Icon(
                notificationState.notificationScreenIsVisible
                    ? Icons.notifications
                    : Icons.notifications_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                BlocProvider.of<NotificationBloc>(context).add(
                  ChangeNotificationScreenVisibilityEvent(
                    show: !notificationState.notificationScreenIsVisible,
                  ),
                );
              },
            ),

            // Connection Status Indicator (Small Dot)
            Positioned(
              left: 9,
              top: 9,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color:
                      notificationState.isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 0.5,
                  ), // White border for visibility
                ),
              ),
            ),

            // Unseen Notifications Badge
            if (unseenNotifications > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      unseenNotifications > 99 ? '99+' : '$unseenNotifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
