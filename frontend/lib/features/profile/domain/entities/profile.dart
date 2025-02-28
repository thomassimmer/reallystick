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
}
