// features/auth/data/repositories/auth_repository.dart

import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/private_messages/data/errors/data_error.dart';
import 'package:reallystick/features/private_messages/data/models/private_discussion.dart';
import 'package:reallystick/features/private_messages/data/models/private_message.dart';
import 'package:reallystick/features/private_messages/data/models/requests/private_discussion.dart';
import 'package:reallystick/features/private_messages/data/models/requests/private_discussion_participation.dart';
import 'package:reallystick/features/private_messages/data/models/requests/private_message.dart';
import 'package:reallystick/features/private_messages/domain/errors/domain_error.dart';

class PrivateMessageRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  PrivateMessageRemoteDataSource({
    required this.apiClient,
    required this.baseUrl,
  });

  Future<PrivateDiscussionDataModel> createPrivateDiscussion(
      PrivateDiscussionCreateRequestModel requestModel) async {
    final url = Uri.parse('$baseUrl/private-discussions/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return PrivateDiscussionDataModel.fromJson(jsonBody['discussion']);
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

  Future<PrivateMessageDataModel> createPrivateMessage(
      PrivateMessageCreateRequestModel requestModel) async {
    final url = Uri.parse('$baseUrl/private-messages/');
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
        return PrivateMessageDataModel.fromJson(jsonBody['message']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 400) {
      if (responseCode == 'PRIVATE_MESSAGE_CONTENT_EMPTY') {
        throw PrivateMessageContentEmptyError();
      }

      if (responseCode == 'PRIVATE_MESSAGE_CONTENT_TOO_LONG') {
        throw PrivateMessageContentTooLongError();
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

  Future<void> deletePrivateMessage(String messageId) async {
    final url = Uri.parse('$baseUrl/private-messages/?message_id=$messageId');
    final response = await apiClient.delete(url);

    if (response.statusCode == 200) {
      return; // Successfully deleted
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<List<PrivateMessageDataModel>> getPrivateMessagesOfDiscussion(
    String discussionId,
    DateTime? beforeDate,
  ) async {
    Uri url = Uri.parse('$baseUrl/private-messages/$discussionId');

    if (beforeDate != null) {
      url = url.addParameters({"before_date": beforeDate});
    }

    final response = await apiClient.get(
      url,
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return (jsonBody['messages'] as List)
            .map((m) => PrivateMessageDataModel.fromJson(m))
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

  Future<List<PrivateDiscussionDataModel>> getPrivateDiscussions() async {
    final url = Uri.parse('$baseUrl/private-discussions/');
    final response = await apiClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        final discussions = jsonBody['discussions'] as List<dynamic>;
        return discussions
            .map(
                (discussion) => PrivateDiscussionDataModel.fromJson(discussion))
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

  Future<PrivateMessageDataModel> markPrivateMessageAsSeen(
      String privateMessageId) async {
    final url =
        Uri.parse('$baseUrl/private-messages/mark-as-seen/$privateMessageId');
    final response = await apiClient.get(url);

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return PrivateMessageDataModel.fromJson(jsonBody['message']);
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

  Future<void> updatePrivateDiscussionParticipation({
    required String discussionId,
    required PrivateDiscussionParticipationUpdateRequestModel requestModel,
  }) async {
    final url =
        Uri.parse('$baseUrl/private-discussion-participations/$discussionId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(requestModel.toJson()),
    );

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

  Future<PrivateMessageDataModel> updatePrivateMessage({
    required String messageId,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/private-messages/$messageId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return PrivateMessageDataModel.fromJson(jsonBody['message']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 400) {
      if (responseCode == 'PRIVATE_MESSAGE_CONTENT_EMPTY') {
        throw PrivateMessageContentEmpty();
      }

      if (responseCode == 'PRIVATE_MESSAGE_CONTENT_TOO_LONG') {
        throw PrivateMessageContentTooLong();
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
