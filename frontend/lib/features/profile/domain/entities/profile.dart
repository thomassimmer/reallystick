class Profile {
  String id;
  String username;
  String locale;
  String theme;
  String? otpBase32;
  String? otpAuthUrl;
  bool otpVerified;
  bool passwordIsExpired;
  bool isAdmin;
  String? publicKey;
  String? privateKeyEncrypted;
  String? saltUsedToDerivateKeyFromPassword;

  bool notificationsEnabled;
  bool notificationsForPrivateMessagesEnabled;
  bool notificationsForPublicMessageLikedEnabled;
  bool notificationsForPublicMessageRepliesEnabled;
  bool notificationsUserJoinedYourChallengeEnabled;
  bool notificationsUserDuplicatedYourChallengeEnabled;

  bool hasSeenQuestions;
  String? ageCategory;
  String? gender;
  String? continent;
  String? country;
  String? region;
  String? activity;
  String? financialSituation;
  bool? livesInUrbanArea;
  String? relationshipStatus;
  String? levelOfEducation;
  bool? hasChildren;

  Profile({
    required this.id,
    required this.username,
    required this.locale,
    required this.theme,
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

  Profile copyWith({
    String? id,
    String? username,
    String? locale,
    String? theme,
    String? otpBase32,
    String? otpAuthUrl,
    bool? otpVerified,
    bool? passwordIsExpired,
    bool? isAdmin,
    String? publicKey,
    String? privateKeyEncrypted,
    String? saltUsedToDerivateKeyFromPassword,
    bool? notificationsEnabled,
    bool? notificationsForPrivateMessagesEnabled,
    bool? notificationsForPublicMessageLikedEnabled,
    bool? notificationsForPublicMessageRepliesEnabled,
    bool? notificationsUserJoinedYourChallengeEnabled,
    bool? notificationsUserDuplicatedYourChallengeEnabled,
    bool? hasSeenQuestions,
    String? ageCategory,
    String? gender,
    String? continent,
    String? country,
    String? region,
    String? activity,
    String? financialSituation,
    bool? livesInUrbanArea,
    String? relationshipStatus,
    String? levelOfEducation,
    bool? hasChildren,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      locale: locale ?? this.locale,
      theme: theme ?? this.theme,
      otpBase32: otpBase32 ?? this.otpBase32,
      otpAuthUrl: otpAuthUrl ?? this.otpAuthUrl,
      otpVerified: otpVerified ?? this.otpVerified,
      passwordIsExpired: passwordIsExpired ?? this.passwordIsExpired,
      isAdmin: isAdmin ?? this.isAdmin,
      publicKey: publicKey ?? this.publicKey,
      privateKeyEncrypted: privateKeyEncrypted ?? this.privateKeyEncrypted,
      saltUsedToDerivateKeyFromPassword: saltUsedToDerivateKeyFromPassword ??
          this.saltUsedToDerivateKeyFromPassword,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationsForPrivateMessagesEnabled:
          notificationsForPrivateMessagesEnabled ??
              this.notificationsForPrivateMessagesEnabled,
      notificationsForPublicMessageLikedEnabled:
          notificationsForPublicMessageLikedEnabled ??
              this.notificationsForPublicMessageLikedEnabled,
      notificationsForPublicMessageRepliesEnabled:
          notificationsForPublicMessageRepliesEnabled ??
              this.notificationsForPublicMessageRepliesEnabled,
      notificationsUserJoinedYourChallengeEnabled:
          notificationsUserJoinedYourChallengeEnabled ??
              this.notificationsUserJoinedYourChallengeEnabled,
      notificationsUserDuplicatedYourChallengeEnabled:
          notificationsUserDuplicatedYourChallengeEnabled ??
              this.notificationsUserDuplicatedYourChallengeEnabled,
      hasSeenQuestions: hasSeenQuestions ?? this.hasSeenQuestions,
      ageCategory: ageCategory ?? this.ageCategory,
      gender: gender ?? this.gender,
      continent: continent ?? this.continent,
      country: country ?? this.country,
      region: region ?? this.region,
      activity: activity ?? this.activity,
      financialSituation: financialSituation ?? this.financialSituation,
      livesInUrbanArea: livesInUrbanArea ?? this.livesInUrbanArea,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      levelOfEducation: levelOfEducation ?? this.levelOfEducation,
      hasChildren: hasChildren ?? this.hasChildren,
    );
  }
}
