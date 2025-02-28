import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/data/models/otp_request_model.dart';
import 'package:reallystick/features/auth/data/models/save_keys_request_model.dart';
import 'package:reallystick/features/auth/data/models/save_recovery_code_request_model.dart';
import 'package:reallystick/features/auth/data/models/two_factor_authentication_config.dart';
import 'package:reallystick/features/auth/data/models/user_data_before_otp_verified_model.dart';
import 'package:reallystick/features/auth/data/models/user_token_model.dart';
import 'package:reallystick/features/auth/data/models/user_token_request_model.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';

class AuthRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  AuthRemoteDataSource({required this.apiClient, required this.baseUrl});

  Future<UserTokenDataModel> signup(
    RegisterUserRequestModel registerUserRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/auth/signup');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(registerUserRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 201) {
      try {
        return UserTokenDataModel.fromJson(jsonBody);
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
      if (responseCode == 'USERNAME_WRONG_SIZE') {
        throw UsernameWrongSizeError();
      }
      if (responseCode == 'USERNAME_NOT_RESPECTING_RULES') {
        throw UsernameNotRespectingRulesError();
      }
    }

    if (response.statusCode == 409) {
      if (responseCode == 'USER_ALREADY_EXISTS') {
        throw UserAlreadyExistingError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<Either<UserTokenDataModel, UserDataBeforeOtpVerifiedModel>> login(
      LoginUserRequestModel loginUserRequestModel) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await apiClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(loginUserRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        if (responseCode == 'USER_LOGGED_IN_WITHOUT_OTP') {
          return Left(
            UserTokenDataModel.fromJson(jsonBody),
          );
        }

        if (responseCode == 'USER_LOGS_IN_WITH_OTP_ENABLED') {
          return Right(
            UserDataBeforeOtpVerifiedModel.fromJson(jsonBody),
          );
        }

        throw ParsingError();
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_PASSWORD') {
        throw InvalidUsernameOrPasswordError();
      }

      throw UnauthorizedError();
    }

    if (response.statusCode == 403) {
      if (responseCode == 'PASSWORD_MUST_BE_CHANGED') {
        throw PasswordMustBeChangedError();
      }

      throw ForbiddenError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<TwoFactorAuthenticationConfigDataModel>
      generateTwoFactorAuthenticationConfig() async {
    final url = Uri.parse('$baseUrl/auth/otp/generate');
    final response = await apiClient.get(
      url,
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return TwoFactorAuthenticationConfigDataModel.fromJson(jsonBody);
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

  Future<bool> verifyOneTimePassword(
      VerifyOneTimePasswordRequestModel
          verifyOneTimePasswordRequestModel) async {
    final url = Uri.parse('$baseUrl/auth/otp/verify');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(verifyOneTimePasswordRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return jsonBody['otp_verified'] as bool;
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_ONE_TIME_PASSWORD') {
        throw InvalidOneTimePasswordError();
      }

      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<UserTokenDataModel> validateOneTimePassword(
      ValidateOneTimePasswordRequestModel
          validateOneTimePasswordRequestModel) async {
    final url = Uri.parse('$baseUrl/auth/otp/validate');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(validateOneTimePasswordRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return UserTokenDataModel.fromJson(jsonBody);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'InvalidOneTimePassword') {
        throw InvalidOneTimePasswordError();
      }

      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'USER_NOT_FOUND') {
        throw UserNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<bool> disableTwoFactorAuthentication() async {
    final url = Uri.parse('$baseUrl/auth/otp/disable');
    final response = await apiClient.get(url);

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return jsonBody['two_fa_enabled'] as bool;
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

  Future<bool> checkIfAccountHasTwoFactorAuthenticationEnabled(
    CheckIfAccountHasTwoFactorAuthenticationEnabledRequestModel
        checkIfAccountHasTwoFactorAuthenticationEnabledRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/users/is-otp-enabled');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        checkIfAccountHasTwoFactorAuthenticationEnabledRequestModel.toJson(),
      ),
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return jsonBody['otp_enabled'] as bool;
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<UserTokenDataModel>
      recoverAccountWithTwoFactorAuthenticationAndPassword(
          RecoverAccountWithRecoveryCodeAndPasswordRequestModel
              recoverAccountWithRecoveryCodeAndPasswordRequestModel) async {
    final url = Uri.parse('$baseUrl/auth/recover-using-password');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        recoverAccountWithRecoveryCodeAndPasswordRequestModel.toJson(),
      ),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return UserTokenDataModel.fromJson(jsonBody);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_PASSWORD_OR_RECOVERY_CODE') {
        throw InvalidUsernameOrPasswordOrRecoveryCodeError();
      }

      throw UnauthorizedError();
    }

    if (response.statusCode == 403) {
      if (responseCode == 'TWO_FACTOR_AUTHENTICATION_NOT_ENABLED') {
        throw TwoFactorAuthenticationNotEnabledError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<UserTokenDataModel>
      recoverAccountWithTwoFactorAuthenticationAndOneTimePassword(
          RecoverAccountWithRecoveryCodeAndOneTimePasswordRequestModel
              recoverAccountWithRecoveryCodeAndOneTimePasswordRequestModel) async {
    final url = Uri.parse('$baseUrl/auth/recover-using-2fa');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        recoverAccountWithRecoveryCodeAndOneTimePasswordRequestModel.toJson(),
      ),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return UserTokenDataModel.fromJson(jsonBody);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_CODE_OR_RECOVERY_CODE') {
        throw InvalidUsernameOrCodeOrRecoveryCodeError();
      }

      throw UnauthorizedError();
    }

    if (response.statusCode == 403) {
      if (responseCode == 'TWO_FACTOR_AUTHENTICATION_NOT_ENABLED') {
        throw TwoFactorAuthenticationNotEnabledError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<UserTokenDataModel>
      recoverAccountWithoutTwoFactorAuthenticationEnabled(
          RecoverAccountWithRecoveryCodeRequestModel
              recoverAccountWithRecoveryCodeRequestModel) async {
    final url = Uri.parse('$baseUrl/auth/recover');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(recoverAccountWithRecoveryCodeRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return UserTokenDataModel.fromJson(jsonBody);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'INVALID_USERNAME_OR_RECOVERY_CODE') {
        throw InvalidUsernameOrRecoveryCodeError();
      }

      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/auth/logout');
    final response = await apiClient.get(
      url,
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

  Future<void> saveKeys(SaveKeysRequestModel saveKeysRequestModel) async {
    final url = Uri.parse('$baseUrl/auth/save-keys');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(saveKeysRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 201) {
      try {
        return;
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      if (responseCode == 'USER_HAS_ALREADY_KEYS') {
        throw UserHasAlreadyKeysError();
      }
    }

    if (response.statusCode == 404) {
      if (responseCode == 'USER_NOT_FOUND') {
        throw UserNotFoundError();
      }

      throw UnauthorizedError();
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> saveRecoveryCode(
      SaveRecoveryCodeRequestModel saveRecoveryCodeRequestModel) async {
    final url = Uri.parse('$baseUrl/auth/save-recovery-code');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(saveRecoveryCodeRequestModel.toJson()),
    );

    if (response.statusCode == 201) {
      try {
        return;
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }
}
