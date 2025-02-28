// features/auth/data/repositories/auth_repository.dart

import 'dart:async';
import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/challenges/data/errors/data_error.dart';
import 'package:reallystick/features/challenges/data/models/challenge.dart';
import 'package:reallystick/features/challenges/data/models/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/data/models/challenge_participation.dart';
import 'package:reallystick/features/challenges/data/models/challenge_statistic.dart';
import 'package:reallystick/features/challenges/data/models/requests/challenge.dart';
import 'package:reallystick/features/challenges/data/models/requests/challenge_daily_tracking.dart';
import 'package:reallystick/features/challenges/data/models/requests/challenge_participation.dart';
import 'package:reallystick/features/habits/data/errors/data_error.dart';

class ChallengeRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  ChallengeRemoteDataSource({required this.apiClient, required this.baseUrl});

  Future<List<ChallengeDataModel>> getChallenges() async {
    final url = Uri.parse('$baseUrl/challenges/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> challenges = jsonBody['challenges'];
        return challenges
            .map((challenge) => ChallengeDataModel.fromJson(challenge))
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

  Future<ChallengeDataModel> getChallenge(String challengeId) async {
    final url = Uri.parse('$baseUrl/challenges/$challengeId');
    final response = await apiClient.get(url);

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return ChallengeDataModel.fromJson(jsonBody['challenge']);
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
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<List<ChallengeParticipationDataModel>>
      getChallengeParticipations() async {
    final url = Uri.parse('$baseUrl/challenge-participations/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> challengeParticipations =
            jsonBody['challenge_participations'];
        return challengeParticipations
            .map((challengeParticipation) =>
                ChallengeParticipationDataModel.fromJson(
                    challengeParticipation))
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

  Future<List<ChallengeDailyTrackingDataModel>> getChallengeDailyTrackings(
      String challengeId) async {
    final url = Uri.parse('$baseUrl/challenge-daily-trackings/$challengeId');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> challengeDailyTrackings =
            jsonBody['challenge_daily_trackings'];
        return challengeDailyTrackings
            .map((challengeDailyTracking) =>
                ChallengeDailyTrackingDataModel.fromJson(
                    challengeDailyTracking))
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

  Future<List<ChallengeDailyTrackingDataModel>> getChallengesDailyTrackings(
      ChallengeDailyTrackingsGetRequestModel
          challengeDailyTrackingsGetRequestModel) async {
    final url =
        Uri.parse('$baseUrl/challenge-daily-trackings/multiple-challenges/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(
        challengeDailyTrackingsGetRequestModel.toJson(),
      ),
    );

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> challengeDailyTrackings =
            jsonBody['challenge_daily_trackings'];
        return challengeDailyTrackings
            .map((challengeDailyTracking) =>
                ChallengeDailyTrackingDataModel.fromJson(
                    challengeDailyTracking))
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

  Future<List<ChallengeStatisticDataModel>> getChallengeStatistics() async {
    final url = Uri.parse('$baseUrl/challenge-statistics/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> statistics = jsonBody['statistics'];
        return statistics
            .map((statistic) => ChallengeStatisticDataModel.fromJson(statistic))
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

  Future<ChallengeDataModel> createChallenge(
      ChallengeCreateRequestModel challengeCreateRequestModel) async {
    final url = Uri.parse('$baseUrl/challenges/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(challengeCreateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return ChallengeDataModel.fromJson(jsonBody['challenge']);
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

  Future<ChallengeParticipationDataModel> createChallengeParticipation(
      ChallengeParticipationCreateRequestModel
          challengeParticipationCreateRequestModel) async {
    final url = Uri.parse('$baseUrl/challenge-participations/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(challengeParticipationCreateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return ChallengeParticipationDataModel.fromJson(
          jsonBody['challenge_participation'],
        );
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
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<ChallengeDailyTrackingDataModel> createChallengeDailyTracking(
      ChallengeDailyTrackingCreateRequestModel
          challengeDailyTrackingCreateRequestModel) async {
    final url = Uri.parse('$baseUrl/challenge-daily-trackings/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(challengeDailyTrackingCreateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return ChallengeDailyTrackingDataModel.fromJson(
            jsonBody['challenge_daily_tracking']);
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

  Future<ChallengeDataModel> updateChallenge(
    String challengeId,
    ChallengeUpdateRequestModel challengeUpdateRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/challenges/$challengeId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(challengeUpdateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return ChallengeDataModel.fromJson(jsonBody['challenge']);
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
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<ChallengeParticipationDataModel> updateChallengeParticipation(
    String challengeParticipationId,
    ChallengeParticipationUpdateRequestModel
        challengeParticipationUpdateRequestModel,
  ) async {
    final url = Uri.parse(
        '$baseUrl/challenge-participations/$challengeParticipationId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(challengeParticipationUpdateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return ChallengeParticipationDataModel.fromJson(
            jsonBody['challenge_participation']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'CHALLENGE_PARTICIPATION_NOT_FOUND') {
        throw ChallengeParticipationNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<ChallengeDailyTrackingDataModel> updateChallengeDailyTracking(
    String challengeDailyTrackingId,
    ChallengeDailyTrackingUpdateRequestModel
        challengeDailyTrackingUpdateRequestModel,
  ) async {
    final url = Uri.parse(
        '$baseUrl/challenge-daily-trackings/$challengeDailyTrackingId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(challengeDailyTrackingUpdateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return ChallengeDailyTrackingDataModel.fromJson(
            jsonBody['challenge_daily_tracking']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'CHALLENGE_DAILY_TRACKING_NOT_FOUND') {
        throw ChallengeDailyTrackingNotFoundError();
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

  Future<void> deleteChallenge(
    String challengeId,
  ) async {
    final url = Uri.parse('$baseUrl/challenges/$challengeId');
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
      if (responseCode == 'CHALLENGE_NOT_FOUND') {
        throw ChallengeNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deleteChallengeParticipation(
    String challengeParticipationId,
  ) async {
    final url = Uri.parse(
        '$baseUrl/challenge-participations/$challengeParticipationId');
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
      if (responseCode == 'CHALLENGE_PARTICIPATION_NOT_FOUND') {
        throw ChallengeParticipationNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deleteChallengeDailyTracking(
    String challengeDailyTrackingId,
  ) async {
    final url = Uri.parse(
        '$baseUrl/challenge-daily-trackings/$challengeDailyTrackingId');
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
      if (responseCode == 'CHALLENGE_DAILY_TRACKING_NOT_FOUND') {
        throw ChallengeDailyTrackingNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }
}
