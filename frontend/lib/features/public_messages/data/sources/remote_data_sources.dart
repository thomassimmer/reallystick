// features/auth/data/repositories/auth_repository.dart

import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/challenges/data/errors/data_error.dart';
import 'package:reallystick/features/habits/data/errors/data_error.dart';
import 'package:reallystick/features/public_messages/data/errors/data_error.dart';
import 'package:reallystick/features/public_messages/data/models/public_message.dart';
import 'package:reallystick/features/public_messages/data/models/public_message_report.dart';
import 'package:reallystick/features/public_messages/data/models/requests/public_message.dart';
import 'package:reallystick/features/public_messages/data/models/requests/public_message_report.dart';

class PublicMessageRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  PublicMessageRemoteDataSource({
    required this.apiClient,
    required this.baseUrl,
  });

  Future<List<PublicMessageDataModel>> getPublicMessages(
    String? challengeId,
    String? habitId,
  ) async {
    String urlString = '$baseUrl/public-messages/';

    if (challengeId != null) {
      urlString += '?challenge_id=$challengeId';
    } else if (habitId != null) {
      urlString += '?habit_id=$habitId';
    }

    final url = Uri.parse(urlString);

    final response = await apiClient.get(url);

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        final List<dynamic> messages = jsonBody['messages'];
        return messages
            .map((message) => PublicMessageDataModel.fromJson(message))
            .toList();
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'CHALLENGE_NOT_FOUND') {
        throw ChallengeNotFoundError();
      }
      if (responseCode == 'HABIT_NOT_FOUND') {
        throw HabitNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<List<PublicMessageDataModel>> getParentMessages(
      String messageId) async {
    final url = Uri.parse('$baseUrl/public-messages/parents/$messageId');
    final response = await apiClient.get(url);

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        final List<dynamic> messages = jsonBody['messages'];
        return messages
            .map((message) => PublicMessageDataModel.fromJson(message))
            .toList();
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<List<PublicMessageDataModel>> getReplies(String messageId) async {
    final url = Uri.parse('$baseUrl/public-messages/replies/$messageId');
    final response = await apiClient.get(url);

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        final List<dynamic> messages = jsonBody['messages'];
        return messages
            .map((message) => PublicMessageDataModel.fromJson(message))
            .toList();
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<List<PublicMessageDataModel>> getLikedMessages() async {
    final url = Uri.parse('$baseUrl/public-messages/liked/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> messages = jsonBody['messages'];
        return messages
            .map((message) => PublicMessageDataModel.fromJson(message))
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

  Future<List<PublicMessageDataModel>> getWrittenMessages() async {
    final url = Uri.parse('$baseUrl/public-messages/written/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> messages = jsonBody['messages'];
        return messages
            .map((message) => PublicMessageDataModel.fromJson(message))
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

  Future<PublicMessageDataModel> createPublicMessage(
      PublicMessageCreateRequestModel requestModel) async {
    final url = Uri.parse('$baseUrl/public-messages/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return PublicMessageDataModel.fromJson(jsonBody['message']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 400) {
      if (responseCode == 'PUBLIC_MESSAGE_CONTENT_TOO_LONG') {
        throw PublicMessageContentTooLongError();
      }
      if (responseCode == 'PUBLIC_MESSAGE_CONTENT_EMPTY') {
        throw PublicMessageContentEmptyError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'CHALLENGE_NOT_FOUND') {
        throw ChallengeNotFoundError();
      }
      if (responseCode == 'HABIT_NOT_FOUND') {
        throw HabitNotFoundError();
      }
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<PublicMessageDataModel> updatePublicMessage(
      String messageId, PublicMessageUpdateRequestModel requestModel) async {
    final url = Uri.parse('$baseUrl/public-messages/$messageId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return PublicMessageDataModel.fromJson(jsonBody['message']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 400) {
      if (responseCode == 'PUBLIC_MESSAGE_CONTENT_TOO_LONG') {
        throw PublicMessageContentTooLongError();
      }
      if (responseCode == 'PUBLIC_MESSAGE_CONTENT_EMPTY') {
        throw PublicMessageContentEmptyError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deletePublicMessage(
      String messageId, bool deletedByAdmin) async {
    final url = Uri.parse(
        '$baseUrl/public-messages/?message_id=$messageId&deleted_by_admin=$deletedByAdmin');
    final response = await apiClient.delete(url);

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<(List<PublicMessageReportDataModel>, List<PublicMessageDataModel>)>
      getMessageReports() async {
    final url = Uri.parse('$baseUrl/public-message-reports/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> reportData = jsonBody['message_reports'];
        final List<dynamic> messageData = jsonBody['messages'];

        final reportDataModels = reportData
            .map((report) => PublicMessageReportDataModel.fromJson(report))
            .toList();

        final messageDataModels = messageData
            .map((message) => PublicMessageDataModel.fromJson(message))
            .toList();

        return (reportDataModels, messageDataModels);
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

  Future<(List<PublicMessageReportDataModel>, List<PublicMessageDataModel>)>
      getUserMessageReports() async {
    final url = Uri.parse('$baseUrl/public-message-reports/me');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> reportData = jsonBody['message_reports'];
        final List<dynamic> messageData = jsonBody['messages'];

        final reportDataModels = reportData
            .map((report) => PublicMessageReportDataModel.fromJson(report))
            .toList();

        final messageDataModels = messageData
            .map((message) => PublicMessageDataModel.fromJson(message))
            .toList();

        return (reportDataModels, messageDataModels);
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

  Future<PublicMessageReportDataModel> createPublicMessageReport(
      PublicMessageReportCreateRequestModel request) async {
    final url = Uri.parse('$baseUrl/public-message-reports/');
    final body = request.toJson();
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return PublicMessageReportDataModel.fromJson(
            jsonBody['message_report']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 400) {
      if (responseCode == 'PUBLIC_MESSAGE_REPORT_REASON_TOO_LONG') {
        throw PublicMessageReportReasonTooLongError();
      }
      if (responseCode == 'PUBLIC_MESSAGE_REPORT_REASON_EMPTY') {
        throw PublicMessageReportReasonEmptyError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deletePublicMessageReport(String messageReportId) async {
    final url = Uri.parse('$baseUrl/public-message-reports/$messageReportId/');
    final response = await apiClient.delete(url);

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> createPublicMessageLike({required String messageId}) async {
    final url = Uri.parse('$baseUrl/public-message-likes/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'message_id': messageId}),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deletePublicMessageLike(String messageId) async {
    final url = Uri.parse('$baseUrl/public-message-likes/$messageId');
    final response = await apiClient.delete(url);

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<PublicMessageDataModel> getMessage(String messageId) async {
    final url = Uri.parse('$baseUrl/public-messages/$messageId');
    final response = await apiClient.get(url);

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return PublicMessageDataModel.fromJson(jsonBody['message']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'PUBLIC_MESSAGE_NOT_FOUND') {
        throw PublicMessageNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }
}
