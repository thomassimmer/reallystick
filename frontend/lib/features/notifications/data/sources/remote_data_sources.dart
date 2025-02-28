// features/auth/data/repositories/auth_repository.dart

import 'dart:async';
import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/notifications/data/models/notification.dart';

class NotificationRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  NotificationRemoteDataSource(
      {required this.apiClient, required this.baseUrl});

  Future<List<NotificationDataModel>> getNotifications() async {
    final url = Uri.parse('$baseUrl/notifications/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> notifications = jsonBody['notifications'];
        return notifications
            .map((notification) => NotificationDataModel.fromJson(notification))
            .toList();
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> markNotificationAsSeen(
    String notificationId,
  ) async {
    final url =
        Uri.parse('$baseUrl/notifications/mark-as-seen/$notificationId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        return;
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deleteNotification(
    String notificationId,
  ) async {
    final url = Uri.parse('$baseUrl/notifications/$notificationId');
    final response = await apiClient.delete(url);

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deleteAllNotifications() async {
    final url = Uri.parse('$baseUrl/notifications/');
    final response = await apiClient.delete(url);

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> saveFcmToken(
    String fcmToken,
  ) async {
    final url = Uri.parse('$baseUrl/notifications/save-fcm-token');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({"fcm_token": fcmToken}),
    );

    if (response.statusCode == 200) {
      try {
        return;
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }
}
