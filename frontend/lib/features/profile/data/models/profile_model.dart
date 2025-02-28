import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String username;
  final String locale;
  final String theme;
  final String? otpBase32;
  final String? otpAuthUrl;
  final bool otpVerified;
  final bool passwordIsExpired;

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

  const ProfileModel(
      {required this.username,
      required this.locale,
      required this.theme,
      required this.otpBase32,
      required this.otpAuthUrl,
      required this.otpVerified,
      required this.passwordIsExpired,
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
      this.hasChildren});

  // Factory constructor to create a ProfileModel from JSON data
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
        username: json['username'] as String,
        locale: json['locale'] as String,
        theme: json['theme'] as String,
        otpBase32: json['otp_base32'] as String?,
        otpAuthUrl: json['otp_auth_url'] as String?,
        otpVerified: json['otp_verified'] as bool,
        passwordIsExpired: json['password_is_expired'] as bool,
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

  @override
  List<Object?> get props => [
        username,
        locale,
        theme,
        otpBase32,
        otpAuthUrl,
        otpVerified,
        passwordIsExpired,
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
