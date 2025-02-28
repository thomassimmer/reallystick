// features/auth/data/repositories/auth_repository.dart

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:logger/web.dart';
import 'package:reallystick/core/messages/errors/data_error.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/features/auth/data/errors/data_error.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/profile/data/errors/data_error.dart';
import 'package:reallystick/features/profile/data/models/country.dart';
import 'package:reallystick/features/profile/data/models/requests.dart';
import 'package:reallystick/features/profile/data/sources/local_data_sources.dart';
import 'package:reallystick/features/profile/data/sources/remote_data_sources.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/domain/errors/domain_error.dart';
import 'package:reallystick/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final logger = Logger();

  ProfileRepositoryImpl(
      {required this.remoteDataSource, required this.localDataSource});

  @override
  Future<Either<DomainError, Profile>> getProfileInformation() async {
    try {
      final profileDataModel = await remoteDataSource.getProfileInformation();

      return Right(profileDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, Profile>> postProfileInformation(
      Profile profile) async {
    try {
      final profileDataModel = await remoteDataSource.postProfileInformation(
          UpdateProfileRequestModel(
              username: profile.username,
              locale: profile.locale,
              theme: profile.theme,
              hasSeenQuestions: profile.hasSeenQuestions,
              ageCategory: profile.ageCategory,
              gender: profile.gender,
              continent: profile.continent,
              country: profile.country,
              region: profile.region,
              activity: profile.activity,
              financialSituation: profile.financialSituation,
              livesInUrbanArea: profile.livesInUrbanArea,
              relationshipStatus: profile.relationshipStatus,
              levelOfEducation: profile.levelOfEducation,
              hasChildren: profile.hasChildren));

      return Right(profileDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, Profile>> setPassword(String newPassword) async {
    try {
      final profileDataModel = await remoteDataSource
          .setPassword(SetPasswordRequestModel(newPassword: newPassword));

      return Right(profileDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on PasswordNotExpiredError {
      logger.e('PasswordNotExpiredError occured.');
      return Left(PasswordNotExpiredDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on PasswordTooShortError {
      logger.e('PasswordTooShortError occured.');
      return Left(PasswordTooShortError());
    } on PasswordNotComplexEnoughError {
      logger.e('PasswordNotComplexEnoughError occured.');
      return Left(PasswordNotComplexEnoughError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<Either<DomainError, Profile>> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      final profileDataModel = await remoteDataSource.updatePassword(
          UpdatePasswordRequestModel(
              currentPassword: currentPassword, newPassword: newPassword));

      return Right(profileDataModel.toDomain());
    } on ParsingError {
      logger.e('ParsingError occurred.');
      return Left(InvalidResponseDomainError());
    } on InvalidUsernameOrPasswordError {
      logger.e('InvalidUsernameOrPasswordError occured.');
      return Left(InvalidUsernameOrPasswordDomainError());
    } on UnauthorizedError {
      logger.e('UnauthorizedError occurred.');
      return Left(UnauthorizedDomainError());
    } on InvalidRefreshTokenError {
      logger.e('InvalidRefreshTokenError occured.');
      return Left(InvalidRefreshTokenDomainError());
    } on RefreshTokenNotFoundError {
      logger.e('RefreshTokenNotFoundError occured.');
      return Left(RefreshTokenNotFoundDomainError());
    } on RefreshTokenExpiredError {
      logger.e('RefreshTokenExpiredError occured.');
      return Left(RefreshTokenExpiredDomainError());
    } on PasswordTooShortError {
      logger.e('PasswordTooShortError occured.');
      return Left(PasswordTooShortError());
    } on PasswordNotComplexEnoughError {
      logger.e('PasswordNotComplexEnoughError occured.');
      return Left(PasswordNotComplexEnoughError());
    } on InternalServerError {
      logger.e('InternalServerError occured.');
      return Left(InternalServerDomainError());
    } catch (e) {
      logger.e('Data error occurred: ${e.toString()}');
      return Left(UnknownDomainError());
    }
  }

  @override
  Future<List<Country>> loadCountries() async {
    return await localDataSource.loadCountries();
  }
}
