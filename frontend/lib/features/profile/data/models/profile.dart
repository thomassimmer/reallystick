import 'package:equatable/equatable.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';

class ProfileDataModel extends Equatable {
  final String id;
  final String username;
  final String locale;
  final String theme;
  final String timezone;
  final String? otpBase32;
  final String? otpAuthUrl;
  final bool otpVerified;
  final bool passwordIsExpired;
  final bool isAdmin;
  final String? publicKey;
  final String? privateKeyEncrypted;
  final String? saltUsedToDerivateKeyFromPassword;

  final bool notificationsEnabled;
  final bool notificationsForPrivateMessagesEnabled;
  final bool notificationsForPublicMessageLikedEnabled;
  final bool notificationsForPublicMessageRepliesEnabled;
  final bool notificationsUserJoinedYourChallengeEnabled;
  final bool notificationsUserDuplicatedYourChallengeEnabled;

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
    required this.id,
    required this.username,
    required this.locale,
    required this.theme,
    required this.timezone,
    required this.otpBase32,
    required this.otpAuthUrl,
    required this.otpVerified,
    required this.passwordIsExpired,
    required this.isAdmin,
    required this.hasSeenQuestions,
    required this.publicKey,
    required this.privateKeyEncrypted,
    required this.saltUsedToDerivateKeyFromPassword,
    required this.notificationsEnabled,
    required this.notificationsForPrivateMessagesEnabled,
    required this.notificationsForPublicMessageLikedEnabled,
    required this.notificationsForPublicMessageRepliesEnabled,
    required this.notificationsUserJoinedYourChallengeEnabled,
    required this.notificationsUserDuplicatedYourChallengeEnabled,
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
        id: json['id'] as String,
        username: json['username'] as String,
        locale: json['locale'] as String,
        theme: json['theme'] as String,
        timezone: json['timezone'] as String,
        otpBase32: json['otp_base32'] as String?,
        otpAuthUrl: json['otp_auth_url'] as String?,
        otpVerified: json['otp_verified'] as bool,
        passwordIsExpired: json['password_is_expired'] as bool,
        isAdmin: json['is_admin'] as bool,
        publicKey: json['public_key'] as String?,
        privateKeyEncrypted: json['private_key_encrypted'] as String?,
        saltUsedToDerivateKeyFromPassword:
            json['salt_used_to_derive_key_from_password'] as String?,
        notificationsEnabled: json['notifications_enabled'] as bool,
        notificationsForPrivateMessagesEnabled:
            json['notifications_for_private_messages_enabled'] as bool,
        notificationsForPublicMessageLikedEnabled:
            json['notifications_for_public_message_liked_enabled'] as bool,
        notificationsForPublicMessageRepliesEnabled:
            json['notifications_for_public_message_replies_enabled'] as bool,
        notificationsUserJoinedYourChallengeEnabled:
            json['notifications_user_joined_your_challenge_enabled'] as bool,
        notificationsUserDuplicatedYourChallengeEnabled:
            json['notifications_user_duplicated_your_challenge_enabled']
                as bool,
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
        id: id,
        username: username,
        locale: locale,
        theme: theme,
        timezone: timezone,
        otpBase32: otpBase32,
        otpAuthUrl: otpAuthUrl,
        otpVerified: otpVerified,
        passwordIsExpired: passwordIsExpired,
        isAdmin: isAdmin,
        publicKey: publicKey,
        privateKeyEncrypted: privateKeyEncrypted,
        saltUsedToDerivateKeyFromPassword: saltUsedToDerivateKeyFromPassword,
        notificationsEnabled: notificationsEnabled,
        notificationsForPrivateMessagesEnabled:
            notificationsForPrivateMessagesEnabled,
        notificationsForPublicMessageLikedEnabled:
            notificationsForPublicMessageLikedEnabled,
        notificationsForPublicMessageRepliesEnabled:
            notificationsForPublicMessageRepliesEnabled,
        notificationsUserJoinedYourChallengeEnabled:
            notificationsUserJoinedYourChallengeEnabled,
        notificationsUserDuplicatedYourChallengeEnabled:
            notificationsUserDuplicatedYourChallengeEnabled,
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
        id,
        username,
        locale,
        theme,
        timezone,
        otpBase32,
        otpAuthUrl,
        otpVerified,
        passwordIsExpired,
        publicKey,
        privateKeyEncrypted,
        saltUsedToDerivateKeyFromPassword,
        notificationsEnabled,
        notificationsForPrivateMessagesEnabled,
        notificationsForPublicMessageLikedEnabled,
        notificationsForPublicMessageRepliesEnabled,
        notificationsUserJoinedYourChallengeEnabled,
        notificationsUserDuplicatedYourChallengeEnabled,
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
