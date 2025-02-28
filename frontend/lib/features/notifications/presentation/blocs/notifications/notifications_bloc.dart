import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/notifications/data/models/notification.dart';
import 'package:reallystick/features/notifications/domain/usecases/delete_all_notifications_usecase.dart';
import 'package:reallystick/features/notifications/domain/usecases/delete_notification_usecase.dart';
import 'package:reallystick/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:reallystick/features/notifications/domain/usecases/mark_notification_as_seen_usecase.dart';
import 'package:reallystick/features/notifications/domain/usecases/save_fcm_token_usecase.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_events.dart';
import 'package:reallystick/features/notifications/presentation/blocs/notifications/notifications_states.dart';
import 'package:reallystick/features/notifications/presentation/helpers/websocket_service.dart';
import 'package:reallystick/features/private_messages/data/models/private_message.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState>
    with WidgetsBindingObserver {
  final AuthBloc authBloc = GetIt.instance<AuthBloc>();
  final ProfileBloc profileBloc = GetIt.instance<ProfileBloc>();
  final PrivateMessageBloc privateMessageBloc =
      GetIt.instance<PrivateMessageBloc>();

  final WebSocketService webSocketService = GetIt.instance<WebSocketService>();

  late StreamSubscription<String> _webSocketSubscription;
  late StreamSubscription profileBlocSubscription;

  final GetNotificationsUsecase getNotificationsUsecase =
      GetIt.instance<GetNotificationsUsecase>();
  final MarkNotificationAsSeenUsecase markNotificationAsSeenUsecase =
      GetIt.instance<MarkNotificationAsSeenUsecase>();
  final DeleteNotificationUsecase deleteNotificationUsecase =
      GetIt.instance<DeleteNotificationUsecase>();
  final DeleteAllNotificationsUsecase deleteAllNotificationsUsecase =
      GetIt.instance<DeleteAllNotificationsUsecase>();
  final SaveFcmTokenUsecase saveFcmTokenUsecase =
      GetIt.instance<SaveFcmTokenUsecase>();

  NotificationBloc()
      : super(NotificationState(
          notifications: [],
          notification: null,
          notificationScreenIsVisible: false,
          isConnected: false,
        )) {
    profileBlocSubscription = profileBloc.stream.listen(
      (profileState) async {
        if (profileState is ProfileAuthenticated) {
          add(InitializeNotificationsEvent());
        } else {
          webSocketService.disconnect();
        }
      },
    );

    on<NotificationReceivedEvent>(
      onNotificationReceived,
      transformer: sequential(),
    );
    on<InitializeNotificationsEvent>(initialize);
    on<MarkNotificationAsSeenEvent>(markNotificationAsSeen);
    on<DeleteNotificationEvent>(deleteNotification);
    on<DeleteAllNotificationsEvent>(deleteAllNotifications);
    on<ChangeNotificationScreenVisibilityEvent>(
        toggleNotificationScreenVisibility);
    on<ChangeUserConnectionStatusEvent>(handleUserDisconnection);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      Future.microtask(
        () {
          webSocketService.disconnect();
        },
      );
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _webSocketSubscription.cancel();
    return super.close();
  }

  Future<void> handleNotificationPermissions() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission when user is authenticated
    await messaging.requestPermission(
      provisional: true,
    );

    String? fcmToken;

    if (Platform.isIOS) {
      final apnsToken = await messaging.getAPNSToken();
      if (apnsToken != null) {
        fcmToken = await messaging.getToken();
      }
    } else {
      fcmToken = await messaging.getToken();
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await saveFcmTokenUsecase.call(fcmToken: newToken);
    }).onError((err) {
      print("Error getting token: $err");
    });

    if (fcmToken != null) {
      await saveFcmTokenUsecase.call(fcmToken: fcmToken);
    }

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        add(
          NotificationReceivedEvent(
            notification:
                NotificationDataModel.fromJson(message.data).toDomain(),
          ),
        );
      },
    );
  }

  Future<void> startNotificationSocket() async {
    WidgetsBinding.instance.addObserver(this);

    _webSocketSubscription = webSocketService.messageStream.listen(
      (message) {
        final jsonMessage = jsonDecode(message);
        final type = jsonMessage['type'];
        final data = jsonDecode(jsonMessage['data']);

        if (type == 'private_message_created' ||
            type == 'private_message_updated' ||
            type == 'private_message_deleted' ||
            type == 'private_message_marked_as_seen') {
          final parsedMessage =
              PrivateMessageDataModel.fromJson(data).toDomain();

          privateMessageBloc.add(
            PrivateMessageReceivedEvent(
              message: parsedMessage,
              type: type,
            ),
          );
        } else if (type == 'challenge_joined' ||
            type == 'challenge_duplicated' ||
            type == 'public_message_liked' ||
            type == 'public_message_replied') {
          final parsedNotification =
              NotificationDataModel.fromJson(data).toDomain();

          add(
            NotificationReceivedEvent(
              notification: parsedNotification,
            ),
          );
        }
      },
    );

    webSocketService.connect();
  }

  Future<void> initialize(
    InitializeNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    final getNotificationsResult = await getNotificationsUsecase.call();

    getNotificationsResult.fold((error) {
      if (error is ShouldLogoutError) {
        authBloc.add(
          AuthLogoutEvent(
            message: ErrorMessage(error.messageKey),
          ),
        );
      } else {
        emit(
          NotificationState(
            message: ErrorMessage(error.messageKey),
            notifications: currentState.notifications,
            notification: currentState.notification,
            notificationScreenIsVisible:
                currentState.notificationScreenIsVisible,
            isConnected: currentState.isConnected,
          ),
        );
      }
    }, (notifications) {
      emit(
        NotificationState(
          message: null,
          notifications: notifications,
          notification: currentState.notification,
          notificationScreenIsVisible: currentState.notificationScreenIsVisible,
          isConnected: currentState.isConnected,
        ),
      );
    });

    webSocketService.connectionStream.listen((isConnected) {
      Future.microtask(() {
        add(ChangeUserConnectionStatusEvent(isConnected: isConnected));
      });
    });

    await startNotificationSocket();

    if (!kIsWeb) {
      await handleNotificationPermissions();
    }
  }

  Future<void> onNotificationReceived(
    NotificationReceivedEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    currentState.notifications.add(event.notification);

    emit(
      NotificationState(
        message: null,
        notifications: currentState.notifications,
        notification: event.notification,
        notificationScreenIsVisible: currentState.notificationScreenIsVisible,
        isConnected: currentState.isConnected,
      ),
    );
  }

  Future<void> markNotificationAsSeen(
    MarkNotificationAsSeenEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    final result = await markNotificationAsSeenUsecase.call(
      notificationId: event.notificationId,
    );

    result.fold((error) {
      if (error is ShouldLogoutError) {
        authBloc.add(
          AuthLogoutEvent(
            message: ErrorMessage(error.messageKey),
          ),
        );
      } else {
        emit(
          NotificationState(
            message: ErrorMessage(error.messageKey),
            notifications: currentState.notifications,
            notification: currentState.notification,
            notificationScreenIsVisible:
                currentState.notificationScreenIsVisible,
            isConnected: currentState.isConnected,
          ),
        );
      }
    }, (_) {
      final newNotifications = currentState.notifications
          .map(
            (n) => n.id == event.notificationId ? n.copyWith(seen: true) : n,
          )
          .toList();

      emit(
        NotificationState(
          message: null,
          notifications: newNotifications,
          notification: null,
          notificationScreenIsVisible: currentState.notificationScreenIsVisible,
          isConnected: currentState.isConnected,
        ),
      );
    });
  }

  Future<void> deleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    final result = await deleteNotificationUsecase.call(
      notificationId: event.notificationId,
    );

    result.fold((error) {
      if (error is ShouldLogoutError) {
        authBloc.add(
          AuthLogoutEvent(
            message: ErrorMessage(error.messageKey),
          ),
        );
      } else {
        emit(
          NotificationState(
            message: ErrorMessage(error.messageKey),
            notifications: currentState.notifications,
            notification: currentState.notification,
            notificationScreenIsVisible:
                currentState.notificationScreenIsVisible,
            isConnected: currentState.isConnected,
          ),
        );
      }
    }, (_) {
      final newNotifications = currentState.notifications
          .where((n) => n.id != event.notificationId)
          .toList();

      emit(
        NotificationState(
          message: null,
          notifications: newNotifications,
          notification: currentState.notification,
          notificationScreenIsVisible: currentState.notificationScreenIsVisible,
          isConnected: currentState.isConnected,
        ),
      );
    });
  }

  Future<void> deleteAllNotifications(
    DeleteAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    final result = await deleteAllNotificationsUsecase.call();

    result.fold((error) {
      if (error is ShouldLogoutError) {
        authBloc.add(
          AuthLogoutEvent(
            message: ErrorMessage(error.messageKey),
          ),
        );
      } else {
        emit(
          NotificationState(
            message: ErrorMessage(error.messageKey),
            notifications: currentState.notifications,
            notification: currentState.notification,
            notificationScreenIsVisible:
                currentState.notificationScreenIsVisible,
            isConnected: currentState.isConnected,
          ),
        );
      }
    }, (_) {
      emit(
        NotificationState(
          message: null,
          notifications: [],
          notification: currentState.notification,
          notificationScreenIsVisible: currentState.notificationScreenIsVisible,
          isConnected: currentState.isConnected,
        ),
      );
    });
  }

  Future<void> toggleNotificationScreenVisibility(
    ChangeNotificationScreenVisibilityEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    emit(
      NotificationState(
        message: null,
        notifications: currentState.notifications,
        notification: currentState.notification,
        notificationScreenIsVisible: event.show,
        isConnected: currentState.isConnected,
      ),
    );
  }

  Future<void> handleUserDisconnection(
    ChangeUserConnectionStatusEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;

    if (currentState.isConnected == event.isConnected) return;

    emit(
      NotificationState(
        message: event.isConnected
            ? SuccessMessage('connected')
            : ErrorMessage('disconnected'),
        notifications: currentState.notifications,
        notification: currentState.notification,
        notificationScreenIsVisible: currentState.notificationScreenIsVisible,
        isConnected: event.isConnected,
      ),
    );
  }
}
