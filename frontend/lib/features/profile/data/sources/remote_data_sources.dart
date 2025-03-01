// features/auth/data/repositories/auth_repository.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/profile/data/errors/data_error.dart';
import 'package:reallystick/features/profile/data/models/device_model.dart';
import 'package:reallystick/features/profile/data/models/profile.dart';
import 'package:reallystick/features/profile/data/models/requests.dart';
import 'package:reallystick/features/profile/data/models/statistics_model.dart';

class ProfileRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  ProfileRemoteDataSource({required this.apiClient, required this.baseUrl});

  Future<ProfileDataModel> getProfileInformation() async {
    final url = Uri.parse('$baseUrl/users/me');
    final response = await apiClient.get(
      url,
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return ProfileDataModel.fromJson(jsonBody['user']);
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

  Future<ProfileDataModel> postProfileInformation(
      UpdateProfileRequestModel profile) async {
    final url = Uri.parse('$baseUrl/users/me');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(profile.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return ProfileDataModel.fromJson(jsonBody['user']);
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

  Future<ProfileDataModel> setPassword(
      SetPasswordRequestModel setPasswordRequestModel) async {
    final url = Uri.parse('$baseUrl/users/set-password');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(setPasswordRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return ProfileDataModel.fromJson(jsonBody['user']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'PASSWORD_TOO_SHORT') {
        throw PasswordTooShortError();
      }
      if (responseCode == 'PASSWORD_TOO_WEAK') {
        throw PasswordNotComplexEnoughError();
      }

      throw UnauthorizedError();
    }

    if (response.statusCode == 403) {
      if (responseCode == 'PASSWORD_NOT_EXPIRED') {
        throw PasswordNotExpiredError();
      }

      throw ForbiddenError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<ProfileDataModel> updatePassword(
      UpdatePasswordRequestModel updatePasswordRequestModel) async {
    final url = Uri.parse('$baseUrl/users/update-password');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(updatePasswordRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return ProfileDataModel.fromJson(jsonBody['user']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_PASSWORD') {
        throw InvalidUsernameOrPasswordError();
      }

      if (responseCode == 'PASSWORD_TOO_SHORT') {
        throw PasswordTooShortError();
      }
      if (responseCode == 'PASSWORD_TOO_WEAK') {
        throw PasswordNotComplexEnoughError();
      }

      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deleteAccount() async {
    final url = Uri.parse('$baseUrl/users/me');
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

  Future<List<DeviceModel>> getDevices() async {
    final url = Uri.parse('$baseUrl/devices/');
    final response = await apiClient.get(url);

    final jsonBody = json.decode(response.body);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> devices = jsonBody['devices'];
        return devices.map((device) => DeviceModel.fromJson(device)).toList();
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

  Future<void> deleteDevice(String deviceId) async {
    final url = Uri.parse('$baseUrl/devices/$deviceId');
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

  Future<StatisticsDataModel> getStatistics() async {
    final url = Uri.parse('${baseUrl.replaceFirst(
      dotenv.env['API_BASE_URL'] ?? '',
      dotenv.env['WS_BASE_URL'] ?? '',
    )}/statistics/');
    final response = await apiClient.get(url);

    final jsonBody = json.decode(response.body);

    if (response.statusCode == 200) {
      try {
        return StatisticsDataModel.fromJson(jsonBody);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 403) {
      throw ForbiddenError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }
}
