// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get aboutText => 'This application is proposed to you by Tanya Simmer.';

  @override
  String get account => 'Account';

  @override
  String get accountDeletionSuccessful => 'You successfully deleted your account.';

  @override
  String get activity => 'Activity';

  @override
  String get addActivity => 'Add an activity';

  @override
  String get addDailyObjective => 'Add a daily objective';

  @override
  String get addNewChallenge => 'Add a New Challenge';

  @override
  String get addNewDiscussion => 'Add a New Discussion';

  @override
  String get addNewHabit => 'Add a New Habit';

  @override
  String get admin => 'Admin';

  @override
  String get ageCategory => 'Age category';

  @override
  String allActivitiesOnThisDay(int count) {
    return 'All activities on this day ($count)';
  }

  @override
  String get allHabits => 'All habits';

  @override
  String get allReportedMessages => 'All Reported Messages';

  @override
  String get alreadyAnAccountLogin => 'Already have an account? Sign in';

  @override
  String get analytics => 'Analytics';

  @override
  String get analyticsInfoTooltip => 'These statistics are refreshed every hour.';

  @override
  String get and => 'and';

  @override
  String get answers => 'Answers';

  @override
  String get atLeastOneTranslationNeededError => 'At least one translation is needed.';

  @override
  String get availableOnIosAndroidWebIn => 'Available on iOS, Android, Web in';

  @override
  String get average => 'Average';

  @override
  String get blockThisUser => 'Block this user';

  @override
  String get bySigningUpYouAgree => 'By signing up, you agree to our ';

  @override
  String get cancel => 'Cancel';

  @override
  String get category => 'Category';

  @override
  String get challengeCreated => 'Your challenge was successfully created.';

  @override
  String get challengeDailyTracking => 'Daily Objectives';

  @override
  String get challengeDailyTrackingCreated => 'This daily objective was successfully created.';

  @override
  String get challengeDailyTrackingDeleted => 'This daily objective was successfully deleted.';

  @override
  String get challengeDailyTrackingNotFoundError => 'This daily objective does not exist.';

  @override
  String get challengeDailyTrackingNoteTooLong => 'The note must be less than 10 000 characters.';

  @override
  String get challengeDailyTrackingUpdated => 'Your changes were saved.';

  @override
  String get challengeDeleted => 'Your challenge was successfully deleted.';

  @override
  String get challengeDescriptionWrongSize => 'The challenge description must be less than 2,000 characters.';

  @override
  String get challengeDuplicated => 'This challenge was successfully copied.';

  @override
  String get challengeFinished => 'Challenge finished';

  @override
  String get challengeName => 'Challenge Name';

  @override
  String get challengeNameWrongSizeError => 'Challenge name must not be empty and less than 100 characters.';

  @override
  String get challengeNotFoundError => 'This challenge does not exist.';

  @override
  String get challengeParticipationCreated => 'You successfully joined this habit.';

  @override
  String get challengeParticipationDeleted => 'Your participation to this challenge was successfully removed.';

  @override
  String get challengeParticipationNotFoundError => 'You don\'t seem to be participating to this challenge.';

  @override
  String get challengeParticipationStartDate => 'Challenge joined on:';

  @override
  String get challengeParticipationUpdated => 'Your changes were saved.';

  @override
  String get challengeUpdated => 'Your changes were saved.';

  @override
  String get challengeWasDeletedByCreator => 'This challenge was removed by its creator';

  @override
  String get challenges => 'Challenges';

  @override
  String get challengesInfoTooltip => 'This information is refreshed every hour.';

  @override
  String get changeChallengeParticipationStartDate => 'Change participation start date';

  @override
  String get changeColor => 'Change color';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changeRecoveryCode => 'Change Recovery Code';

  @override
  String get chooseAnIcon => 'Choose an icon';

  @override
  String get comeBack => 'Come Back';

  @override
  String get comingSoon => 'Coming soon...';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmDelete => 'Confirm account deletion';

  @override
  String get confirmDeleteMessage => 'By clicking \"Confirm\", your account and all associated activity will be scheduled for permanent deletion in 3 days.\n\nIf you log in again before this period expires, the deletion will be cancelled.';

  @override
  String get confirmDeletion => 'Confirm Deletion';

  @override
  String get confirmDeletionQuestion => 'Are you sure you want to delete the session on this device?';

  @override
  String get confirmDuplicateChallenge => 'Do you want to create a copy of this challenge with the associated daily objectives?';

  @override
  String get confirmMessageDeletion => 'By clicking on \"Confirm\", this message and all replies will be permanently deleted.';

  @override
  String get connected => 'Online';

  @override
  String get continent => 'Continent';

  @override
  String get copyright => '© Copyright 2025. All rights reserved.';

  @override
  String get country => 'Country';

  @override
  String get create => 'Create';

  @override
  String get createANewChallenge => 'Create a New Challenge';

  @override
  String get createANewHabit => 'Create a New Habit';

  @override
  String get createChallenge => 'Create challenge';

  @override
  String get createHabit => 'Create habit';

  @override
  String get createHabitsThatStick => 'Create Habits That Stick';

  @override
  String createdBy(String creator) {
    return 'Created by $creator';
  }

  @override
  String createdByStartsOn(String creator, String startDate) {
    return 'Created by $creator, starts on: $startDate';
  }

  @override
  String get createdChallenges => 'Created challenges';

  @override
  String get creatorMissingPublicKey => 'You do not have secret keys yet. Log in again to create them.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get dark => 'Dark';

  @override
  String get date => 'Date';

  @override
  String get dateTimeIsInTheFutureError => 'The date can\'t be in the future.';

  @override
  String get dateTimeIsInThePastError => 'The date can\'t be in the past.';

  @override
  String get dayOfProgram => 'Day of the Program';

  @override
  String get defaultError => 'An error occurred. Please try again.';

  @override
  String defaultReminderChallenge(String challenge) {
    return 'Don\'t forget to track your challenge: $challenge';
  }

  @override
  String defaultReminderHabit(String habit) {
    return 'Don\'t forget to track your habit: $habit';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteChallenge => 'Delete challenge';

  @override
  String get deleteChallengeParticipation => 'Delete this participation';

  @override
  String get deleteMessage => 'Delete Message';

  @override
  String get description => 'Description';

  @override
  String descriptionWithTwoPoints(String description) {
    return 'Description: $description';
  }

  @override
  String get deviceDeleteSuccessful => 'You successfully stopped the session on this device';

  @override
  String deviceInfo(String browser, String isMobile, String model, String os) {
    String _temp0 = intl.Intl.selectLogic(
      isMobile,
      {
        'true': 'Mobile device',
        'false': 'Computer',
        'other': 'Unknown',
      },
    );
    String _temp1 = intl.Intl.selectLogic(
      os,
      {
        'null': '. ',
        'other': ' running on $os. ',
      },
    );
    String _temp2 = intl.Intl.selectLogic(
      browser,
      {
        'null': 'App',
        'other': 'Browser: $browser',
      },
    );
    String _temp3 = intl.Intl.selectLogic(
      model,
      {
        'null': '',
        'other': 'Model: $model.',
      },
    );
    return '$_temp0$_temp1$_temp2. $_temp3';
  }

  @override
  String get devices => 'Devices';

  @override
  String get disableTwoFA => 'Disable';

  @override
  String get disconnected => 'Offline';

  @override
  String get discussion => 'Discussion';

  @override
  String get discussions => 'Discussions';

  @override
  String get discussionsComingSoon => 'Some interesting discussions coming soon here...';

  @override
  String get done => 'Done';

  @override
  String get duplicate => 'Make a copy';

  @override
  String get duplicateChallenge => 'Challenge copy';

  @override
  String get duplicationsOfMyChallenges => 'Duplications of your challenges';

  @override
  String get edit => 'Edit';

  @override
  String get editActivity => 'Edit this activity';

  @override
  String get editChallenge => 'Edit this challenge';

  @override
  String get editMessage => 'Edit message';

  @override
  String editedAt(String time) {
    return 'Edited on $time';
  }

  @override
  String get enable => 'Enable';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get enableNotificationsReminder => 'Enable reminder notifications';

  @override
  String get endDate => 'End Date';

  @override
  String get endToEndEncryptedPrivateMessages => 'End-to-end encrypted private messages';

  @override
  String get enterOneTimePassword => 'Enter the 6-digit code generated by your app to confirm your authentication.';

  @override
  String get enterPassword => 'Enter your password.';

  @override
  String get enterRecoveryCode => 'Enter your recovery code.';

  @override
  String get enterUsername => 'Enter your username.';

  @override
  String get enterValidationCode => 'Enter the code from your authentication app.';

  @override
  String get failedToLoadChallenges => 'A failure occured while fetching your challenges.';

  @override
  String get failedToLoadHabits => 'A failure occured while fetching your habits.';

  @override
  String get failedToLoadProfile => 'Failed to load profile';

  @override
  String get female => 'Female';

  @override
  String get females => 'Females';

  @override
  String get financialSituation => 'Financial situation';

  @override
  String get finished => 'Finished';

  @override
  String get fixedDates => 'Fixed dates';

  @override
  String get forbiddenError => 'You are not authorized to perform this action.';

  @override
  String get gender => 'Gender';

  @override
  String get generateNewQrCode => 'Generate a new QR code';

  @override
  String get generateNewRecoveryCode => 'Generate a new recovery code';

  @override
  String get goToTwoFASetup => 'Set up two-factor authentication';

  @override
  String get habit => 'Habit';

  @override
  String get habitCategoryNotFoundError => 'This habit category does not exist.';

  @override
  String get habitCreated => 'Your habit was successfully created.';

  @override
  String get habitDailyTracking => 'Daily Tracking';

  @override
  String get habitDailyTrackingCreated => 'Your activity was successfully created.';

  @override
  String get habitDailyTrackingDeleted => 'Your activity was successfully deleted.';

  @override
  String get habitDailyTrackingNotFoundError => 'This activity does not exist.';

  @override
  String get habitDailyTrackingUpdated => 'Your activity was successfully updated.';

  @override
  String get habitDescriptionWrongSize => 'Description must not be empty and less than 2,000 characters.';

  @override
  String get habitIsEmptyError => 'A habit must be selected.';

  @override
  String get habitName => 'Habit name';

  @override
  String get habitNameWrongSizeError => 'Habit name must not be empty and less than 100 characters.';

  @override
  String get habitNotFoundError => 'This habit does not exist.';

  @override
  String get habitParticipationCreated => 'You successfully joined this habit.';

  @override
  String get habitParticipationDeleted => 'Your participation to this habit was successfully removed.';

  @override
  String get habitParticipationNotFoundError => 'You don\'t seem to be participating to this habit.';

  @override
  String get habitParticipationUpdated => 'Your changes were saved.';

  @override
  String get habitUpdated => 'Your habit was successfully updated.';

  @override
  String get habits => 'Habits';

  @override
  String get habitsConcerned => 'Habits Concerned';

  @override
  String get habitsNotMergedError => 'These two habits could not be merged.';

  @override
  String get hasChildren => 'Parent of children';

  @override
  String hello(String userName) {
    return 'Hello $userName';
  }

  @override
  String get highSchoolOrLess => 'High school or less';

  @override
  String get highSchoolPlusFiveOrMoreYears => 'High school + 5 years of studies or more';

  @override
  String get highSchoolPlusOneOrTwoYears => 'High school + 1 or 2 years of studies';

  @override
  String get highSchoolPlusThreeOrFourYears => 'High school + 3 or 4 years of studies';

  @override
  String get home => 'Home';

  @override
  String get icon => 'Icon';

  @override
  String get iconEmptyError => 'An icon is needed.';

  @override
  String get iconNotFoundError => 'Habit icon not found.';

  @override
  String get internalServerError => 'An internal server error occurred. Please try again.';

  @override
  String get introductionToQuestions => 'We’re excited to have you here.\n\nTo give you the best experience and share insightful statistics with you, we have a few quick questions for you.\n\nYour honest answers will help us create meaningful, worldwide statistics.\n\nYour answers to these questions cannot reveal your identity.';

  @override
  String get invalidOneTimePasswordError => 'Invalid one-time password. Please try again.';

  @override
  String get invalidRequestError => 'The request you made was not accepted by the server.';

  @override
  String get invalidResponseError => 'The response from the server could not be processed.';

  @override
  String get invalidUsernameOrCodeOrRecoveryCodeError => 'Invalid username, one-time password, or recovery code. Please try again.';

  @override
  String get invalidUsernameOrPasswordError => 'Invalid username or password. Please try again.';

  @override
  String get invalidUsernameOrPasswordOrRecoveryCodeError => 'Invalid username, password, or recovery code. Please try again.';

  @override
  String get invalidUsernameOrRecoveryCodeError => 'Invalid username or recovery code. Please try again.';

  @override
  String get joinChallengeReachYourGoals => 'Join Challenges,\nReach Your Goals';

  @override
  String get joinThisChallenge => 'Participate in this challenge';

  @override
  String joinedByXPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Joined by $count people',
      one: 'Joined by $count person',
      zero: 'Joined by nobody yet',
    );
    return '$_temp0';
  }

  @override
  String joinedOn(String startDate) {
    return 'Joined on: $startDate';
  }

  @override
  String get jumpOnTop => 'Jump to Top';

  @override
  String get keepRecoveryCodeSafe => 'Please keep this recovery code safe.\n\nIt is necessary if you lose your password or access to your 2FA application.';

  @override
  String get language => 'Language';

  @override
  String get lastActivity => 'Last activity:';

  @override
  String get lastActivityDate => 'Last activity date:';

  @override
  String lastActivityDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '$count day ago',
    );
    return '$_temp0';
  }

  @override
  String lastActivityHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '$count hour ago',
    );
    return '$_temp0';
  }

  @override
  String lastActivityMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '$count minute ago',
    );
    return '$_temp0';
  }

  @override
  String lastActivityMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '$count month ago',
    );
    return '$_temp0';
  }

  @override
  String lastActivitySeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds ago',
      one: '$count second ago',
      zero: 'Just now',
    );
    return '$_temp0';
  }

  @override
  String lastActivityYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '$count year ago',
    );
    return '$_temp0';
  }

  @override
  String get levelOfEducation => 'Level of education';

  @override
  String get light => 'Light';

  @override
  String get likedMessages => 'Liked Messages';

  @override
  String get likesOnMyPublicMessages => 'Likes on my public messages';

  @override
  String get livesInUrbanArea => 'Living in urban area';

  @override
  String get livingInRuralArea => 'Rural area';

  @override
  String get livingInUrbanArea => 'Urban area';

  @override
  String get logIn => 'Log In';

  @override
  String get loginSuccessful => 'You successfully logged in.';

  @override
  String get logout => 'Log out';

  @override
  String get logoutSuccessful => 'You successfully logged out.';

  @override
  String get longName => 'Long name';

  @override
  String get male => 'Male';

  @override
  String get males => 'Males';

  @override
  String get markChallengeAsFinished => 'You arrived at the end of this challenge, congratulations!\nMark it as finished to do it again later without losing the details of this participation.';

  @override
  String get markedAsFinishedChallenges => 'Finished challenges';

  @override
  String get mergeHabit => 'Merge Habit';

  @override
  String get message => 'Message';

  @override
  String get messageDeletedError => 'This message has been deleted.';

  @override
  String get messageNotFoundError => 'Message not found.';

  @override
  String get messages => 'Messages';

  @override
  String get messagesAreEncrypted => 'Messages are end-to-end encrypted.\nNo one outside of this chat, not even our team, can read them.';

  @override
  String get missingDateTimeError => 'The date can\'t be left empty.';

  @override
  String get missingUnitError => 'A unit must be selected.';

  @override
  String get newDiscussion => 'New Discussion';

  @override
  String get newParticipantsToMyChallenges => 'New participants to my challenges';

  @override
  String get newPassword => 'New password';

  @override
  String get next => 'Next';

  @override
  String get no => 'No';

  @override
  String get noAccountCreateOne => 'No account? Create one here.';

  @override
  String get noActivityRecordedYet => 'No activity recorded yet.';

  @override
  String get noAnswer => 'I prefer to not answer';

  @override
  String get noAnswerForThisMessageYet => 'No answer for this message yet.';

  @override
  String get noChallengeDailyTrackingYet => 'No daily objectives set yet.';

  @override
  String get noChallengesForHabitYet => 'No challenges yet.\nCreate the first challenge for this habit!';

  @override
  String get noChallengesYet => 'You do not have challenges yet.';

  @override
  String get noConcernedHabitsYet => 'There are no concerned habits in this challenge yet.';

  @override
  String get noConnection => 'We\'re currently unable to connect to our servers. Please check your connection or try again shortly.';

  @override
  String get noContent => 'No content to display';

  @override
  String get noDeviceInfo => 'No device information to display';

  @override
  String get noDevices => 'No device to display';

  @override
  String get noDiscussionsForChallengeYet => 'No discussions yet.\nCreate the first discussion for this challenge!';

  @override
  String get noDiscussionsForHabitYet => 'No discussions yet.\nCreate the first discussion for this habit!';

  @override
  String get noEmailOfIdentifiableDataRequired => 'No email or identifiable data required';

  @override
  String get noHabitsYet => 'You do not have habits yet.';

  @override
  String get noLikedMessages => 'You did not like any message yet.';

  @override
  String get noMessagesYet => 'There are no message yet in this discussion.';

  @override
  String get noNotification => 'You do not have notifications yet.';

  @override
  String get noPrivateDiscussionsYet => 'You do not have any private discussion yet.';

  @override
  String get noRecoveryCodeAvailable => 'No recovery code available.';

  @override
  String get noReportedMessages => 'You did not report any message yet.';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get noWrittenMessages => 'You did not write any message yet.';

  @override
  String get note => 'Note';

  @override
  String get noteWithNote => 'Note:';

  @override
  String get notifications => 'Notifications';

  @override
  String get numberOfDaysToRepeatThisObjective => 'Number of days to repeat this objective';

  @override
  String numberOfParticipantsInChallenge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people participate in this challenge.',
      one: '$count person participates in this challenge.',
      zero: 'No one participates in this challenge.',
    );
    return '$_temp0';
  }

  @override
  String get numberOfParticipantsInChallengeTitle => 'Number of participants';

  @override
  String numberOfParticipantsInHabit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people participate in this habit.',
      one: '$count person participates in this habit.',
      zero: 'No one participates in this habit.',
    );
    return '$_temp0';
  }

  @override
  String get numberOfParticipantsInHabitTitle => 'Number of participants';

  @override
  String get ongoingChallenges => 'Ongoing challenges';

  @override
  String get other => 'Other';

  @override
  String get otherChallenges => 'Other challenges';

  @override
  String get participateAgain => 'Participate again';

  @override
  String get password => 'Password';

  @override
  String get passwordForgotten => 'Forgot your password?';

  @override
  String get passwordMustBeChangedError => 'You need to change your password to log in.';

  @override
  String get passwordNotComplexEnough => 'Your password must contain at least a letter, a digit, and a special character.';

  @override
  String get passwordNotExpiredError => 'Your password is not expired, so it cannot be changed this way.';

  @override
  String get passwordTooShortError => 'Your password must be at least 8 characters long.';

  @override
  String get passwordUpdateSuccessful => 'Your password was successfully updated.';

  @override
  String get peopleWithChildren => 'People with children';

  @override
  String get peopleWithoutChildren => 'People without children';

  @override
  String get personalizedNotificationsToStayOnTrack => 'Personalized notifications to stay on track';

  @override
  String get pleaseLoginOrSignUp => 'Please log in or sign up to continue.';

  @override
  String get poor => 'Poor';

  @override
  String get previous => 'Previous';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyMarkdown => '# Privacy Policy\n\n**Effective Date:** April 5, 2025  \n**Last Updated:** April 5, 2025\n\nWelcome to **ReallyStick**, a social habit-tracking platform that enables users to track their daily progress, join challenges, and engage in public or private discussions — all while maintaining control over their personal data.\n\n## 1. Information We Collect\n\n### Required Data\n- Username\n- Password (hashed securely)\n- Recovery Code\n- Device Information (OS, platform, type)\n- IP Address\n- Session Tokens\n\n### Optional Demographics\n- Continent\n- Country\n- Age category\n- Gender\n- Level of study\n- Level of wealth\n- Employment status\n\n## 2. Private Messaging & Encryption\n\n- End-to-end encrypted private messages\n- Your private key is stored only on your device\n- We cannot read your private messages\n\n## 3. How We Use Your Data\n\nWe use your data to:\n- Provide app functionality\n- Manage device sessions\n- Generate anonymous analytics\n- Send push notifications (via Google Firebase)\n- Monitor abuse and maintain security\n\nWe do **not** sell or share your data for advertising.\n\n## 4. Data Sharing\n\nOnly external service:  \n- Google Firebase – used for push notifications. Firebase may collect device identifiers and token information to deliver messages. We do not share personally identifiable data with Firebase.\n\n## 5. Public Interactions\n\n- Only usernames are shown publicly\n- Public messages can be reported and moderated\n\n## 6. Data Retention & Deletion\n\nUsers can delete their account and all related data from their profile page.\n\n## 7. Security Measures\n\n- Hashed passwords\n- Local token storage\n- End-to-end encryption\n- IP logging for abuse prevention\n\n## 8. Anonymity & Identity\n\n- No email or real names required\n- Accounts are pseudonymous\n\n## 9. Children’s Privacy\n\nOur app is open to all users, but parental consent may be required depending on your local laws.\n\n## 10. User Rights (GDPR)\n\n- Access your data\n- Delete your data\n- Opt out of optional data fields\n\n## 11. Policy Changes\n\nWe may update this Privacy Policy. You’ll be notified in-app if we make major changes.\n\n## 12. Contact Us\n\nUse the in-app contact form\n\nFor privacy-related inquiries, you may also email us at: **[support@reallystick.com](support@reallystick.com)**';

  @override
  String get privateDiscussionNotFoundError => 'The private discussion could not be found.';

  @override
  String get privateMessageContentEmpty => 'The private message content cannot be empty.';

  @override
  String get privateMessageContentTooLong => 'The private message content must be less than 10,000 characters.';

  @override
  String get privateMessageNotFoundError => 'The private message could not be found.';

  @override
  String get privateMessagesReceived => 'Private messages received';

  @override
  String get profile => 'Profile';

  @override
  String get profileInformation => 'Profile Information';

  @override
  String get profileSettings => 'Profile Settings';

  @override
  String get profileUpdateSuccessful => 'Profile information saved.';

  @override
  String get publicMessageContentEmpty => 'The public message content cannot be empty.';

  @override
  String get publicMessageContentTooLong => 'The public message content must be less than 10,000 characters.';

  @override
  String get publicMessageDeletionSuccessful => 'Your message was successfully deleted.';

  @override
  String get publicMessageNotFoundError => 'The public message could not be found.';

  @override
  String get publicMessageReportCreationSuccessful => 'Your report was succesfully sent.';

  @override
  String get publicMessageReportNotFoundError => 'The report for the public message could not be found.';

  @override
  String get publicMessageReportReasonEmpty => 'The reason for reporting must not be empty.';

  @override
  String get publicMessageReportReasonTooLong => 'The reason for reporting must be less than 10,000 characters.';

  @override
  String get qrCodeSecretKeyCopied => 'QR code secret key copied to clipboard.';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityIsNotANumberError => 'Quantity must be a number.';

  @override
  String get quantityOfSet => 'Quantity of set';

  @override
  String get quantityOfSetIsNegativeError => 'The quantity of set can\'t be negative.';

  @override
  String get quantityOfSetIsNullError => 'The quantity of set can\'t be null.';

  @override
  String quantityOfSetWithQuantity(int quantity) {
    return 'Quantity of set: $quantity';
  }

  @override
  String get quantityPerSet => 'Quantity per set';

  @override
  String get quantityPerSetIsNegativeError => 'The quantity can\'t be negative.';

  @override
  String get quantityPerSetIsNullError => 'The quantity can\'t be empty.';

  @override
  String quantityPerSetWithQuantity(String quantity) {
    return 'Quantity per set: $quantity';
  }

  @override
  String quantityWithQuantity(String quantity) {
    return 'Quantity: $quantity';
  }

  @override
  String get questionActivity => 'What is your current activity?';

  @override
  String get questionAge => 'How old are you?';

  @override
  String get questionFinancialSituation => 'How would you describe your financial situation?';

  @override
  String get questionGender => 'Are you a male or female?';

  @override
  String get questionHasChildren => 'Do you have children?';

  @override
  String get questionLevelOfEducation => 'What is your level of education?';

  @override
  String get questionLivingInUrbanArea => 'Are you living in an urban area?';

  @override
  String get questionLocation => 'Where do you live?';

  @override
  String get questionRelationStatus => 'Are you now in a relation?';

  @override
  String get questionsAnswered => 'Your answers were saved. We thank you!';

  @override
  String get quitThisChallenge => 'Quit this challenge';

  @override
  String get quitThisHabit => 'Quit this habit';

  @override
  String get reason => 'Reason';

  @override
  String get recipientMissingPublicKey => 'This recipient does not have secret keys yet.';

  @override
  String get recoverAccount => 'Recover Account';

  @override
  String get recoveryCode => 'Recovery code';

  @override
  String get recoveryCodeCopied => 'Recovery code copied to clipboard.';

  @override
  String get recoveryCodeDescription => 'Your recovery code can be used if you forgot your password.\n\nPlease, keep it confidential.\n\nIf you forgot it, you can generate a new one.\n\nBe aware that this will deactivate the current recovery code.';

  @override
  String get refreshTokenExpiredError => 'Your session has expired. Please log in again.';

  @override
  String get regenerateQrCode => 'Regenerate QR code';

  @override
  String get region => 'Region';

  @override
  String get relatedChallenges => 'Related Challenges';

  @override
  String get relationshipStatus => 'Relationship status';

  @override
  String get relationshipStatusCouple => 'In a relation';

  @override
  String get relationshipStatusSingle => 'Single';

  @override
  String get repeatOnMultipleDaysAfter => 'Repeat on several days after this one';

  @override
  String get repetitionNumberIsNegativeError => 'The repetition number can\'t be negative.';

  @override
  String get repetitionNumberIsNullError => 'The repetition number can\'t be null.';

  @override
  String get repliesOnMyPublicMessages => 'Replies on my public messages';

  @override
  String get reply => 'Reply';

  @override
  String replyTo(String user) {
    return 'Reply to $user...';
  }

  @override
  String get reportMessage => 'Report Message';

  @override
  String get reportedMessages => 'Reported Messages';

  @override
  String get retry => 'Retry';

  @override
  String get reviewHabit => 'Review habit';

  @override
  String get save => 'Save';

  @override
  String get saveHabit => 'Save changes';

  @override
  String get searchChallenges => 'Search Challenges';

  @override
  String get searchHabits => 'Search Habits';

  @override
  String get searchUser => 'Search User';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectLanguageToAddTranslation => 'Select a language to add a translation';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectUnits => 'Select units of measure for this habit';

  @override
  String get setNewPassword => 'Enter your new password.';

  @override
  String get share => 'Share';

  @override
  String get shareChallengeSubject => 'Join a challenge';

  @override
  String shareChallengeText(String link) {
    return 'Hey! This challenge could be interesting for you: $link';
  }

  @override
  String get shortName => 'Short name';

  @override
  String get signUp => 'Sign Up';

  @override
  String get skip => 'Skip';

  @override
  String get startDate => 'Start Date';

  @override
  String get startHabitShort => 'Start';

  @override
  String get startTrackingThisHabit => 'Start tracking this habit';

  @override
  String startsOn(String startDate) {
    return 'Starts on: $startDate';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get student => 'Student';

  @override
  String get tapForMoreDetails => 'Tap for more details';

  @override
  String get tapToSeeLess => 'Tap to see less';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get termsOfUseMarkdown => '# Terms of Use\n\n**Effective Date:** April 5, 2025  \n**Last Updated:** April 5, 2025\n\nWelcome to **ReallyStick**, a social habit-tracking platform designed to help you track and improve your daily habits. By accessing or using the app, you agree to be bound by the following Terms of Use. If you do not agree with these terms, please do not use the app.\n\n## 1. User Accounts\n\nTo use certain features of the app, you must create an account. You agree to:\n- Provide accurate and complete information during the registration process.\n- Keep your account information (username, password, recovery code) confidential.\n- Notify us immediately if you suspect unauthorized access to your account.\n\nYou are responsible for all activities that occur under your account, including any data shared or actions taken through your account.\n\n## 2. Use of the App\n\nYou agree to use **ReallyStick** only for lawful purposes and in accordance with these Terms of Use. You shall not:\n- Violate any applicable laws or regulations.\n- Post, share, or engage in any activity that is harmful, offensive, or illegal.\n- Use the app to send unsolicited messages or spam.\n- Attempt to hack, damage, or gain unauthorized access to the app or its features.\n\nWe reserve the right to suspend or terminate your account if you violate these terms.\n\n## 3. Privacy and Data Collection\n\nYour privacy is important to us. We collect certain data as outlined in our **Privacy Policy**. By using the app, you consent to the collection and use of your data in accordance with our Privacy Policy.\n\n## 4. Content and Ownership\n\n- All content provided by **ReallyStick** (including the app, website, and any related materials) is owned by us or our licensors and is protected by copyright, trademark, and other intellectual property laws.\n- You may not copy, modify, distribute, or create derivative works of any content without our permission.\n- You retain ownership of any content you post within the app, but by posting content, you grant us a license to use, display, and distribute that content within the app and for promotional purposes.\n\n## 5. User-Generated Content\n\nYou are responsible for the content you post or share on **ReallyStick**. This includes text, images, and any other media. You agree not to post:\n- Content that is harmful, harassing, offensive, or discriminatory.\n- Content that infringes on the intellectual property rights of others.\n- Content that violates any applicable laws.\n\nWe reserve the right to remove any content that violates these terms.\n\n## 6. Push Notifications\n\nWe may send you push notifications for updates, reminders, and important app-related information. You can manage or disable these notifications in the app’s settings.\n\n## 7. Termination\n\nWe reserve the right to suspend or terminate your access to **ReallyStick** at any time, for any reason, including if you violate these Terms of Use. Upon termination, your account will be deleted, and you will lose access to the app.\n\n## 8. Disclaimers\n\n- The app is provided \"as-is\" without any warranties of any kind, either express or implied.\n- We do not guarantee that the app will be error-free, secure, or available at all times.\n\n## 9. Limitation of Liability\n\nTo the fullest extent permitted by law, we are not liable for any damages arising from your use or inability to use **ReallyStick**, including but not limited to data loss, system errors, or any other indirect or consequential damages.\n\n## 10. Indemnification\n\nYou agree to indemnify, defend, and hold harmless **ReallyStick** and its affiliates from any claims, damages, liabilities, and expenses (including legal fees) arising from your use of the app, your violation of these Terms of Use, or any content you post or share on the app.\n\n## 11. Governing Law\n\nThese Terms of Use are governed by the laws of the jurisdiction in which you reside. Any disputes will be resolved in the appropriate courts in your region.\n\n## 12. Changes to the Terms\n\nWe may update these Terms of Use from time to time. If we make any material changes, we will notify you within the app. The most current version of these terms will always be available in the app.\n\n## 13. Contact Us\n\nIf you have any questions or concerns regarding these Terms of Use, please contact us using the in-app contact form.';

  @override
  String get theme => 'Theme';

  @override
  String get time => 'Time';

  @override
  String timeWithTime(String time) {
    return 'Time: $time';
  }

  @override
  String get topActivityCardTitle => 'Activity';

  @override
  String get topAgesCardTitle => 'Age categories';

  @override
  String get topCountriesCardTitle => 'Countries';

  @override
  String get topFinancialSituationsCardTitle => 'Financial situation';

  @override
  String get topGenderCardTitle => 'Gender';

  @override
  String get topHasChildrenCardTitle => 'Children';

  @override
  String get topLevelsOfEducationCardTitle => 'Level of education';

  @override
  String get topLivesInUrbanAreaCardTitle => 'Living area';

  @override
  String get topRegionsCardTitle => 'Regions';

  @override
  String get topRelationshipStatusesCardTitle => 'Relationship status';

  @override
  String translationForLanguage(String language) {
    return 'Translation in: $language';
  }

  @override
  String get twoFA => 'Two-Factor Authentication';

  @override
  String get twoFAInvitation => 'Security and privacy are our top priorities.\n\nPlease set up two-factor authentication to protect your account from brute-force attacks.';

  @override
  String get twoFAIsWellSetup => 'Two-Factor Authentication is successfully set up for your account.';

  @override
  String get twoFAScanQrCode => 'Scan this QR code with your authentication app.';

  @override
  String get twoFASecretKey => 'Your QR code secret key is:';

  @override
  String get twoFASetup => 'Enable two-factor authentication to secure your account.';

  @override
  String get twoFactorAuthenticationNotEnabledError => 'Two-factor authentication is not enabled for your account.';

  @override
  String get unableToLoadRecoveryCode => 'Unable to load the recovery code.';

  @override
  String get unauthorizedError => 'You are not authorized to perform this action.';

  @override
  String get unblockThisUser => 'Unblock this user';

  @override
  String get unemployed => 'Unemployed';

  @override
  String get unit => 'Unit';

  @override
  String get unitNotFoundError => 'This unit was not found.';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownError => 'An unexpected error occurred. Please try again.';

  @override
  String get updateChallenge => 'Update challenge';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updatePassword => 'Enter your current and new password.';

  @override
  String get updateRequired => 'A new version is required to continue using the app.';

  @override
  String get userAlreadyExistingError => 'A user with this username already exists. Please choose another.';

  @override
  String get userNotFoundError => 'User not found.';

  @override
  String get username => 'Username';

  @override
  String get usernameNotRespectingRulesError => 'Your username must follow these rules:\n - Start and end with a letter or digit\n - Allowed special characters are . _ -\n - No consecutive special characters';

  @override
  String get usernameWrongSizeError => 'Username length must be between 3 and 20 characters.';

  @override
  String get validationCode => 'Validation code';

  @override
  String get validationCodeCorrect => 'Your validation code is correct!';

  @override
  String get verify => 'Verify';

  @override
  String get wealthy => 'Wealthy';

  @override
  String get weight => 'Weight';

  @override
  String get weightIsNegativeError => 'Weight can\'t be negative.';

  @override
  String get weightUnit => 'Weight Unit';

  @override
  String weightWithQuantity(int quantity, String unit) {
    return 'Weight: $quantity $unit';
  }

  @override
  String get welcome => 'Welcome on ReallyStick';

  @override
  String get whatIsThis => 'What is this?';

  @override
  String get worker => 'Worker';

  @override
  String writeTo(String user) {
    return 'Write to $user...';
  }

  @override
  String get writtenMessages => 'Written Messages';

  @override
  String get yes => 'Yes';

  @override
  String get youAreNotAlone => 'You are not alone.\nTalk. Share. Grow.';

  @override
  String get youAreNotTheCreatorOfThisChallenge => 'You are not the creator of this challenge.';

  @override
  String get youBlockedThisUser => 'You blocked this user.';

  @override
  String get yourMessagesAreLoading => 'Your messages are loading...';
}
