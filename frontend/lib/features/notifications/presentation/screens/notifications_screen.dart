import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_scroll_view.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/notifications/domain/entities/notification.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_events.dart';
import 'package:reallystick/features/notifications/presentation/widgets/notification_widget.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  NotificationsScreenState createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  Future<void> _pullRefresh() async {
    BlocProvider.of<NotificationBloc>(context)
        .add(InitializeNotificationsEvent());
    await Future.delayed(Duration(seconds: 2));
  }

  void deleteAllNotifications() {
    BlocProvider.of<NotificationBloc>(context).add(
      DeleteAllNotificationsEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = context.watch<NotificationBloc>().state;

    final List<Notification> notifications = notificationState.notifications;
    notifications.sort((a, b) => a.createdAt.isBefore(b.createdAt) ? 1 : -1);

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: context.typographies.heading,
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: notificationState.isConnected
                        ? Colors.green
                        : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: notificationState.isConnected
                          ? Colors.green.withAlpha(50)
                          : Colors.red.withAlpha(50),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Text(
                  notificationState.isConnected
                      ? AppLocalizations.of(context)!.connected
                      : AppLocalizations.of(context)!.disconnected,
                ),
              ),
            ),
          ),
          if (notifications.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete,
                size: 24,
              ),
              onPressed: () {
                deleteAllNotifications();
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: FullWidthScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (notifications.isNotEmpty &&
                        index < notifications.length) {
                      final notification = notifications[index];

                      return NotificationsWidget(notification: notification);
                    } else {
                      // Render no notifications message
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                        child: Column(
                          children: [
                            if (notifications.isEmpty)
                              Text(
                                AppLocalizations.of(context)!.noNotification,
                                style: TextStyle(fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      );
                    }
                  },
                  childCount: notifications.isNotEmpty
                      ? notifications.length
                      : 1, // Only show the message and button when no challenges match
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
