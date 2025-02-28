import 'package:equatable/equatable.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';

class ProfileDataModel extends Equatable {
  final String username;
  final String locale;
  final String theme;
  final String? otpBase32;
  final String? otpAuthUrl;
  final bool otpVerified;
  final bool passwordIsExpired;
  final bool isAdmin;

  final bool hasSeenQuestions;
  final String? ageCategory;
  final String? gender;
  final String? continent;
  final String? country;
  final String? region;
  final String? activity;
  final String? financialSituation;
  final bool? livesInUrbanArea;
  final String? relationshipStatus;
  final String? levelOfEducation;
  final bool? hasChildren;

  const ProfileDataModel({
    required this.username,
    required this.locale,
    required this.theme,
    required this.otpBase32,
    required this.otpAuthUrl,
    required this.otpVerified,
    required this.passwordIsExpired,
    required this.isAdmin,
    required this.hasSeenQuestions,
    this.ageCategory,
    this.gender,
    this.continent,
    this.country,
    this.region,
    this.activity,
    this.financialSituation,
    this.livesInUrbanArea,
    this.relationshipStatus,
    this.levelOfEducation,
    this.hasChildren,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
        username: json['username'] as String,
        locale: json['locale'] as String,
        theme: json['theme'] as String,
        otpBase32: json['otp_base32'] as String?,
        otpAuthUrl: json['otp_auth_url'] as String?,
        otpVerified: json['otp_verified'] as bool,
        passwordIsExpired: json['password_is_expired'] as bool,
        isAdmin: json['is_admin'] as bool,
        hasSeenQuestions: json['has_seen_questions'] as bool,
        ageCategory: json['age_category'] as String?,
        gender: json['gender'] as String?,
        continent: json['continent'] as String?,
        country: json['country'] as String?,
        region: json['region'] as String?,
        activity: json['activity'] as String?,
        financialSituation: json['financial_situation'] as String?,
        livesInUrbanArea: json['lives_in_urban_area'] as bool?,
        relationshipStatus: json['relationship_status'] as String?,
        levelOfEducation: json['level_of_education'] as String?,
        hasChildren: json['has_children'] as bool?);
  }

  Profile toDomain() => Profile(
        username: username,
        locale: locale,
        theme: theme,
        otpBase32: otpBase32,
        otpAuthUrl: otpAuthUrl,
        otpVerified: otpVerified,
        passwordIsExpired: passwordIsExpired,
        isAdmin: isAdmin,
        ageCategory: ageCategory,
        gender: gender,
        continent: continent,
        country: country,
        region: region,
        activity: activity,
        financialSituation: financialSituation,
        livesInUrbanArea: livesInUrbanArea,
        relationshipStatus: relationshipStatus,
        levelOfEducation: levelOfEducation,
        hasChildren: hasChildren,
        hasSeenQuestions: hasSeenQuestions,
      );

  @override
  List<Object?> get props => [
        username,
        locale,
        theme,
        otpBase32,
        otpAuthUrl,
        otpVerified,
        passwordIsExpired,
        hasSeenQuestions,
        ageCategory,
        gender,
        continent,
        country,
        region,
        activity,
        financialSituation,
        livesInUrbanArea,
        relationshipStatus,
        levelOfEducation,
        hasChildren,
      ];
}
