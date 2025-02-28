class UpdateProfileRequestModel {
  final String locale;
  final String theme;
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

  final bool notificationsEnabled;
  final bool notificationsForPrivateMessagesEnabled;
  final bool notificationsForPublicMessageLikedEnabled;
  final bool notificationsForPublicMessageRepliesEnabled;
  final bool notificationsUserJoinedYourChallengeEnabled;
  final bool notificationsUserDuplicatedYourChallengeEnabled;

  const UpdateProfileRequestModel({
    required this.locale,
    required this.theme,
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
    required this.notificationsEnabled,
    required this.notificationsForPrivateMessagesEnabled,
    required this.notificationsForPublicMessageLikedEnabled,
    required this.notificationsForPublicMessageRepliesEnabled,
    required this.notificationsUserJoinedYourChallengeEnabled,
    required this.notificationsUserDuplicatedYourChallengeEnabled,
  });

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'theme': theme,
      'has_seen_questions': hasSeenQuestions,
      'age_category': ageCategory,
      'gender': gender,
      'continent': continent,
      'country': country,
      'region': region,
      'activity': activity,
      'financial_situation': financialSituation,
      'lives_in_urban_area': livesInUrbanArea,
      'relationship_status': relationshipStatus,
      'level_of_education': levelOfEducation,
      'has_children': hasChildren,
      'notifications_enabled': notificationsEnabled,
      'notifications_for_private_messages_enabled':
          notificationsForPrivateMessagesEnabled,
      'notifications_for_public_message_liked_enabled':
          notificationsForPublicMessageLikedEnabled,
      'notifications_for_public_message_replies_enabled':
          notificationsForPublicMessageRepliesEnabled,
      'notifications_user_joined_your_challenge_enabled':
          notificationsUserJoinedYourChallengeEnabled,
      'notifications_user_duplicated_your_challenge_enabled':
          notificationsUserDuplicatedYourChallengeEnabled,
    };
  }
}

class SetPasswordRequestModel {
  final String newPassword;

  const SetPasswordRequestModel({required this.newPassword});

  Map<String, dynamic> toJson() {
    return {
      'new_password': newPassword,
    };
  }
}

class UpdatePasswordRequestModel {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordRequestModel(
      {required this.currentPassword, required this.newPassword});

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
    };
  }
}
