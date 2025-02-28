// features/auth/data/repositories/auth_repository.dart

import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/users/data/models/requests/user_public_data.dart';
import 'package:reallystick/features/users/data/models/user_public_data_model.dart';

class UserPublicDataRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  UserPublicDataRemoteDataSource({
    required this.apiClient,
    required this.baseUrl,
  });

  Future<List<UserPublicDataModel>> getUserPublicData(
    GetUserPublicDataRequestModel getUserPublicDataRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/users/');

    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(getUserPublicDataRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> users = jsonBody['users'];
        return users.map((user) => UserPublicDataModel.fromJson(user)).toList();
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
