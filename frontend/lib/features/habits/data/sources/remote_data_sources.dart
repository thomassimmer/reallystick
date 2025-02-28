// features/auth/data/repositories/auth_repository.dart

import 'dart:async';
import 'dart:convert';

import 'package:http_interceptor/http_interceptor.dart';
import 'package:reallystick/core/constants/json_decode.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/habits/data/errors/data_error.dart';
import 'package:reallystick/features/habits/data/models/habit.dart';
import 'package:reallystick/features/habits/data/models/habit_category.dart';
import 'package:reallystick/features/habits/data/models/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/data/models/habit_participation.dart';
import 'package:reallystick/features/habits/data/models/habit_statistic.dart';
import 'package:reallystick/features/habits/data/models/requests/habit.dart';
import 'package:reallystick/features/habits/data/models/requests/habit_category.dart';
import 'package:reallystick/features/habits/data/models/requests/habit_daily_tracking.dart';
import 'package:reallystick/features/habits/data/models/requests/habit_participation.dart';
import 'package:reallystick/features/habits/data/models/requests/unit.dart';
import 'package:reallystick/features/habits/data/models/unit.dart';

class HabitRemoteDataSource {
  final InterceptedClient apiClient;
  final String baseUrl;

  HabitRemoteDataSource({required this.apiClient, required this.baseUrl});

  Future<List<HabitDataModel>> getHabits() async {
    final url = Uri.parse('$baseUrl/habits/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> habits = jsonBody['habits'];
        return habits.map((habit) => HabitDataModel.fromJson(habit)).toList();
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

  Future<List<HabitCategoryDataModel>> getHabitCategories() async {
    final url = Uri.parse('$baseUrl/habit-categories/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> habitCategories = jsonBody['habit_categories'];
        return habitCategories
            .map((habitCategory) =>
                HabitCategoryDataModel.fromJson(habitCategory))
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

  Future<List<HabitParticipationDataModel>> getHabitParticipations() async {
    final url = Uri.parse('$baseUrl/habit-participations/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> habitParticipations =
            jsonBody['habit_participations'];
        return habitParticipations
            .map((habitParticipation) =>
                HabitParticipationDataModel.fromJson(habitParticipation))
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

  Future<List<HabitDailyTrackingDataModel>> getHabitDailyTracking() async {
    final url = Uri.parse('$baseUrl/habit-daily-trackings/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> habitDailyTrackings =
            jsonBody['habit_daily_trackings'];
        return habitDailyTrackings
            .map((habitDailyTracking) =>
                HabitDailyTrackingDataModel.fromJson(habitDailyTracking))
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

  Future<List<UnitDataModel>> getUnits() async {
    final url = Uri.parse('$baseUrl/units/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> units = jsonBody['units'];
        return units.map((unit) => UnitDataModel.fromJson(unit)).toList();
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

  Future<List<HabitStatisticDataModel>> getHabitStatistics() async {
    final url = Uri.parse('$baseUrl/habit-statistics/');
    final response = await apiClient.get(url);

    if (response.statusCode == 200) {
      try {
        final jsonBody = customJsonDecode(response.body);
        final List<dynamic> statistics = jsonBody['statistics'];
        return statistics
            .map((statistic) => HabitStatisticDataModel.fromJson(statistic))
            .toList();
      } catch (e) {
        print(e);
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

  Future<HabitDataModel> createHabit(
      HabitCreateRequestModel habitCreateRequestModel) async {
    final url = Uri.parse('$baseUrl/habits/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(habitCreateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return HabitDataModel.fromJson(jsonBody['habit']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'HABIT_CATEGORY_NOT_FOUND') {
        throw HabitCategoryNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<HabitParticipationDataModel> createHabitParticipation(
      HabitParticipationCreateRequestModel
          habitParticipationCreateRequestModel) async {
    final url = Uri.parse('$baseUrl/habit-participations/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(habitParticipationCreateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return HabitParticipationDataModel.fromJson(
            jsonBody['habit_participation']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'HABIT_NOT_FOUND') {
        throw HabitNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<HabitCategoryDataModel> createHabitCategory(
      HabitCategoryCreateRequestModel habitCategoryCreateRequestModel) async {
    final url = Uri.parse('$baseUrl/habit-categories/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(habitCategoryCreateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return HabitCategoryDataModel.fromJson(jsonBody['habit_category']);
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

  Future<HabitDailyTrackingDataModel> createHabitDailyTracking(
      HabitDailyTrackingCreateRequestModel
          habitDailyTrackingCreateRequestModel) async {
    final url = Uri.parse('$baseUrl/habit-daily-trackings/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(habitDailyTrackingCreateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return HabitDailyTrackingDataModel.fromJson(
            jsonBody['habit_daily_tracking']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'HABIT_NOT_FOUND') {
        throw HabitNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<UnitDataModel> createUnit(
      UnitCreateRequestModel unitCreateRequestModel) async {
    final url = Uri.parse('$baseUrl/units/');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(unitCreateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);

    if (response.statusCode == 200) {
      try {
        return UnitDataModel.fromJson(jsonBody['unit']);
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

  Future<HabitDataModel> updateHabit(
    String habitId,
    HabitUpdateRequestModel habitUpdateRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/habits/$habitId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(habitUpdateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return HabitDataModel.fromJson(jsonBody['habit']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'HABIT_CATEGORY_NOT_FOUND') {
        throw HabitCategoryNotFoundError();
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

  Future<HabitParticipationDataModel> updateHabitParticipation(
    String habitParticipationId,
    HabitParticipationUpdateRequestModel habitParticipationUpdateRequestModel,
  ) async {
    final url =
        Uri.parse('$baseUrl/habit-participations/$habitParticipationId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(habitParticipationUpdateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return HabitParticipationDataModel.fromJson(
            jsonBody['habit_participation']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'HABIT_PARTICIPATION_NOT_FOUND') {
        throw HabitParticipationNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<HabitCategoryDataModel> updateHabitCategory(
    String habitCategoryId,
    HabitCategoryUpdateRequestModel habitCategoryUpdateRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/habit-categories/$habitCategoryId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(habitCategoryUpdateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return HabitCategoryDataModel.fromJson(jsonBody['habit_category']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'HABIT_CATEGORY_NOT_FOUND') {
        throw HabitCategoryNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<HabitDailyTrackingDataModel> updateHabitDailyTracking(
    String habitDailyTrackingId,
    HabitDailyTrackingUpdateRequestModel habitDailyTrackingUpdateRequestModel,
  ) async {
    final url =
        Uri.parse('$baseUrl/habit-daily-trackings/$habitDailyTrackingId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(habitDailyTrackingUpdateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return HabitDailyTrackingDataModel.fromJson(
            jsonBody['habit_daily_tracking']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'HABIT_DAILY_TRACKING_NOT_FOUND') {
        throw HabitDailyTrackingNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<UnitDataModel> updateUnit(
    String unitId,
    UnitUpdateRequestModel unitUpdateRequestModel,
  ) async {
    final url = Uri.parse('$baseUrl/units/$unitId');
    final response = await apiClient.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(unitUpdateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return UnitDataModel.fromJson(jsonBody['unit']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'UNIT_NOT_FOUND') {
        throw UnitNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deleteHabit(
    String habitId,
  ) async {
    final url = Uri.parse('$baseUrl/habits/$habitId');
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
      if (responseCode == 'HABIT_NOT_FOUND') {
        throw HabitNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deleteHabitParticipation(
    String habitParticipationId,
  ) async {
    final url =
        Uri.parse('$baseUrl/habit-participations/$habitParticipationId');
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
      if (responseCode == 'HABIT_PARTICIPATION_NOT_FOUND') {
        throw HabitParticipationNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deleteHabitCategory(
    String habitCategoryId,
  ) async {
    final url = Uri.parse('$baseUrl/habit-categories/$habitCategoryId');
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
      if (responseCode == 'HABIT_CATEGORY_NOT_FOUND') {
        throw HabitCategoryNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<void> deleteHabitDailyTracking(
    String habitDailyTrackingId,
  ) async {
    final url =
        Uri.parse('$baseUrl/habit-daily-trackings/$habitDailyTrackingId');
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
      if (responseCode == 'HABIT_DAILY_TRACKING_NOT_FOUND') {
        throw HabitDailyTrackingNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      throw InternalServerError();
    }

    throw UnknownError();
  }

  Future<HabitDataModel> mergeHabits(
    String habitToDeleteId,
    String habitToMergeOnId,
    HabitUpdateRequestModel habitUpdateRequestModel,
  ) async {
    final url =
        Uri.parse('$baseUrl/habits/merge/$habitToDeleteId/$habitToMergeOnId');
    final response = await apiClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(habitUpdateRequestModel.toJson()),
    );

    final jsonBody = customJsonDecode(response.body);
    final responseCode = jsonBody['code'] as String;

    if (response.statusCode == 200) {
      try {
        return HabitDataModel.fromJson(jsonBody['habit']);
      } catch (e) {
        throw ParsingError();
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedError();
    }

    if (response.statusCode == 404) {
      if (responseCode == 'HABIT_CATEGORY_NOT_FOUND') {
        throw HabitCategoryNotFoundError();
      }
      if (responseCode == 'HABIT_NOT_FOUND') {
        throw HabitNotFoundError();
      }
    }

    if (response.statusCode == 500) {
      if (responseCode == 'HABITS_NOT_MERGED') {
        throw HabitsNotMergedError();
      }
      throw InternalServerError();
    }

    throw UnknownError();
  }
}
