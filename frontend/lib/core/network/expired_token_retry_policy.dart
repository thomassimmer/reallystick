import 'dart:async';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/features/auth/data/services/auth_service.dart';

class ExpiredTokenRetryPolicy implements RetryPolicy {
  final AuthService authService;

  ExpiredTokenRetryPolicy({required this.authService});

  @override
  int maxRetryAttempts = 2;

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    if (response is Response) {
      final jsonBody = customJsonDecode(response.body) as Map<String, dynamic>;
      final responseCode = jsonBody['code'] as String?;

      if (response.statusCode == 401 &&
          (responseCode == 'ACCESS_TOKEN_EXPIRED' ||
              responseCode == 'INVALID_ACCESS_TOKEN')) {
        await authService.refreshToken();

        return true;
      }
    }

    return false;
  }

  @override
  FutureOr<bool> shouldAttemptRetryOnException(
          Exception reason, BaseRequest request) =>
      false;

  @override
  Duration delayRetryAttemptOnException({required int retryAttempt}) =>
      Duration.zero;

  @override
  Duration delayRetryAttemptOnResponse({required int retryAttempt}) =>
      Duration.zero;
}
