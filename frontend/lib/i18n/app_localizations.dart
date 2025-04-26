import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ru')
  ];

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutText.
  ///
  /// In en, this message translates to:
  /// **'This application is proposed to you by Tanya Simmer.'**
  String get aboutText;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountDeletionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'You successfully deleted your account.'**
  String get accountDeletionSuccessful;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add an activity'**
  String get addActivity;

  /// No description provided for @addDailyObjective.
  ///
  /// In en, this message translates to:
  /// **'Add a daily objective'**
  String get addDailyObjective;

  /// No description provided for @addNewChallenge.
  ///
  /// In en, this message translates to:
  /// **'Add a New Challenge'**
  String get addNewChallenge;

  /// No description provided for @addNewDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Add a New Discussion'**
  String get addNewDiscussion;

  /// No description provided for @addNewHabit.
  ///
  /// In en, this message translates to:
  /// **'Add a New Habit'**
  String get addNewHabit;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @ageCategory.
  ///
  /// In en, this message translates to:
  /// **'Age category'**
  String get ageCategory;

  /// No description provided for @allActivitiesOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'All activities on this day ({count})'**
  String allActivitiesOnThisDay(int count);

  /// No description provided for @allHabits.
  ///
  /// In en, this message translates to:
  /// **'All habits'**
  String get allHabits;

  /// No description provided for @allReportedMessages.
  ///
  /// In en, this message translates to:
  /// **'All Reported Messages'**
  String get allReportedMessages;

  /// No description provided for @alreadyAnAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get alreadyAnAccountLogin;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @analyticsInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'These statistics are refreshed every hour.'**
  String get analyticsInfoTooltip;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @answers.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get answers;

  /// No description provided for @atLeastOneTranslationNeededError.
  ///
  /// In en, this message translates to:
  /// **'At least one translation is needed.'**
  String get atLeastOneTranslationNeededError;

  /// No description provided for @availableOnIosAndroidWebIn.
  ///
  /// In en, this message translates to:
  /// **'Available on iOS, Android, Web in'**
  String get availableOnIosAndroidWebIn;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @blockThisUser.
  ///
  /// In en, this message translates to:
  /// **'Block this user'**
  String get blockThisUser;

  /// No description provided for @bySigningUpYouAgree.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our '**
  String get bySigningUpYouAgree;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @challengeCreated.
  ///
  /// In en, this message translates to:
  /// **'Your challenge was successfully created.'**
  String get challengeCreated;

  /// No description provided for @challengeDailyTracking.
  ///
  /// In en, this message translates to:
  /// **'Daily Objectives'**
  String get challengeDailyTracking;

  /// No description provided for @challengeDailyTrackingCreated.
  ///
  /// In en, this message translates to:
  /// **'This daily objective was successfully created.'**
  String get challengeDailyTrackingCreated;

  /// No description provided for @challengeDailyTrackingDeleted.
  ///
  /// In en, this message translates to:
  /// **'This daily objective was successfully deleted.'**
  String get challengeDailyTrackingDeleted;

  /// No description provided for @challengeDailyTrackingNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'This daily objective does not exist.'**
  String get challengeDailyTrackingNotFoundError;

  /// No description provided for @challengeDailyTrackingNoteTooLong.
  ///
  /// In en, this message translates to:
  /// **'The note must be less than 10 000 characters.'**
  String get challengeDailyTrackingNoteTooLong;

  /// No description provided for @challengeDailyTrackingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your changes were saved.'**
  String get challengeDailyTrackingUpdated;

  /// No description provided for @challengeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your challenge was successfully deleted.'**
  String get challengeDeleted;

  /// No description provided for @challengeDuplicated.
  ///
  /// In en, this message translates to:
  /// **'This challenge was successfully copied.'**
  String get challengeDuplicated;

  /// No description provided for @challengeFinished.
  ///
  /// In en, this message translates to:
  /// **'Challenge finished'**
  String get challengeFinished;

  /// No description provided for @challengeName.
  ///
  /// In en, this message translates to:
  /// **'Challenge Name'**
  String get challengeName;

  /// No description provided for @challengeNameWrongSizeError.
  ///
  /// In en, this message translates to:
  /// **'Challenge name must not be empty and less than 100 characters.'**
  String get challengeNameWrongSizeError;

  /// No description provided for @challengeNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'This challenge does not exist.'**
  String get challengeNotFoundError;

  /// No description provided for @challengeParticipationCreated.
  ///
  /// In en, this message translates to:
  /// **'You successfully joined this habit.'**
  String get challengeParticipationCreated;

  /// No description provided for @challengeParticipationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your participation to this challenge was successfully removed.'**
  String get challengeParticipationDeleted;

  /// No description provided for @challengeParticipationNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'You don\'t seem to be participating to this challenge.'**
  String get challengeParticipationNotFoundError;

  /// No description provided for @challengeParticipationStartDate.
  ///
  /// In en, this message translates to:
  /// **'Challenge joined on:'**
  String get challengeParticipationStartDate;

  /// No description provided for @challengeParticipationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your changes were saved.'**
  String get challengeParticipationUpdated;

  /// No description provided for @challengeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your changes were saved.'**
  String get challengeUpdated;

  /// No description provided for @challengeWasDeletedByCreator.
  ///
  /// In en, this message translates to:
  /// **'This challenge was removed by its creator'**
  String get challengeWasDeletedByCreator;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @challengesInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'This information is refreshed every hour.'**
  String get challengesInfoTooltip;

  /// No description provided for @changeChallengeParticipationStartDate.
  ///
  /// In en, this message translates to:
  /// **'Change participation start date'**
  String get changeChallengeParticipationStartDate;

  /// No description provided for @changeColor.
  ///
  /// In en, this message translates to:
  /// **'Change color'**
  String get changeColor;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changeRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Change Recovery Code'**
  String get changeRecoveryCode;

  /// No description provided for @comeBack.
  ///
  /// In en, this message translates to:
  /// **'Come Back'**
  String get comeBack;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon...'**
  String get comingSoon;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm account deletion'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'By clicking \"Confirm\", your account and all associated activity will be scheduled for permanent deletion in 3 days.\n\nIf you log in again before this period expires, the deletion will be cancelled.'**
  String get confirmDeleteMessage;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @confirmDeletionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the session on this device?'**
  String get confirmDeletionQuestion;

  /// No description provided for @confirmDuplicateChallenge.
  ///
  /// In en, this message translates to:
  /// **'Do you want to create a copy of this challenge with the associated daily objectives?'**
  String get confirmDuplicateChallenge;

  /// No description provided for @confirmMessageDeletion.
  ///
  /// In en, this message translates to:
  /// **'By clicking on \"Confirm\", this message and all replies will be permanently deleted.'**
  String get confirmMessageDeletion;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get connected;

  /// No description provided for @continent.
  ///
  /// In en, this message translates to:
  /// **'Continent'**
  String get continent;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© Copyright 2025. All rights reserved.'**
  String get copyright;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createANewChallenge.
  ///
  /// In en, this message translates to:
  /// **'Create a New Challenge'**
  String get createANewChallenge;

  /// No description provided for @createANewHabit.
  ///
  /// In en, this message translates to:
  /// **'Create a New Habit'**
  String get createANewHabit;

  /// No description provided for @createChallenge.
  ///
  /// In en, this message translates to:
  /// **'Create challenge'**
  String get createChallenge;

  /// No description provided for @createHabit.
  ///
  /// In en, this message translates to:
  /// **'Create habit'**
  String get createHabit;

  /// No description provided for @createHabitsThatStick.
  ///
  /// In en, this message translates to:
  /// **'Create Habits That Stick'**
  String get createHabitsThatStick;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by {creator}'**
  String createdBy(String creator);

  /// No description provided for @createdByStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Created by {creator}, starts on: {startDate}'**
  String createdByStartsOn(String creator, String startDate);

  /// No description provided for @createdChallenges.
  ///
  /// In en, this message translates to:
  /// **'Created challenges'**
  String get createdChallenges;

  /// No description provided for @creatorMissingPublicKey.
  ///
  /// In en, this message translates to:
  /// **'You do not have secret keys yet. Log in again to create them.'**
  String get creatorMissingPublicKey;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dateTimeIsInTheFutureError.
  ///
  /// In en, this message translates to:
  /// **'The date can\'t be in the future.'**
  String get dateTimeIsInTheFutureError;

  /// No description provided for @dateTimeIsInThePastError.
  ///
  /// In en, this message translates to:
  /// **'The date can\'t be in the past.'**
  String get dateTimeIsInThePastError;

  /// No description provided for @dayOfProgram.
  ///
  /// In en, this message translates to:
  /// **'Day of the Program'**
  String get dayOfProgram;

  /// No description provided for @defaultError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get defaultError;

  /// No description provided for @defaultReminderChallenge.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to track your challenge: {challenge}'**
  String defaultReminderChallenge(String challenge);

  /// No description provided for @defaultReminderHabit.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to track your habit: {habit}'**
  String defaultReminderHabit(String habit);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteChallenge.
  ///
  /// In en, this message translates to:
  /// **'Delete challenge'**
  String get deleteChallenge;

  /// No description provided for @deleteChallengeParticipation.
  ///
  /// In en, this message translates to:
  /// **'Delete this participation'**
  String get deleteChallengeParticipation;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessage;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionWithTwoPoints.
  ///
  /// In en, this message translates to:
  /// **'Description: {description}'**
  String descriptionWithTwoPoints(String description);

  /// No description provided for @deviceDeleteSuccessful.
  ///
  /// In en, this message translates to:
  /// **'You successfully stopped the session on this device'**
  String get deviceDeleteSuccessful;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'{isMobile, select, true {Mobile device} false {Computer} other {Unknown}}{os, select, null {. } other { running on {os}. }}{browser, select, null {App} other {Browser: {browser}}}. {model, select, null {} other {Model: {model}.}}'**
  String deviceInfo(String browser, String isMobile, String model, String os);

  /// No description provided for @devices.
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get devices;

  /// No description provided for @disableTwoFA.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disableTwoFA;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get disconnected;

  /// No description provided for @discussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// No description provided for @discussions.
  ///
  /// In en, this message translates to:
  /// **'Discussions'**
  String get discussions;

  /// No description provided for @discussionsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Some interesting discussions coming soon here...'**
  String get discussionsComingSoon;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Make a copy'**
  String get duplicate;

  /// No description provided for @duplicateChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge copy'**
  String get duplicateChallenge;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editActivity.
  ///
  /// In en, this message translates to:
  /// **'Edit this activity'**
  String get editActivity;

  /// No description provided for @editChallenge.
  ///
  /// In en, this message translates to:
  /// **'Edit this challenge'**
  String get editChallenge;

  /// No description provided for @editedAt.
  ///
  /// In en, this message translates to:
  /// **'Edited on {time}'**
  String editedAt(String time);

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @enableNotificationsReminder.
  ///
  /// In en, this message translates to:
  /// **'Enable reminder notifications'**
  String get enableNotificationsReminder;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @endToEndEncryptedPrivateMessages.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encrypted private messages'**
  String get endToEndEncryptedPrivateMessages;

  /// No description provided for @enterOneTimePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code generated by your app to confirm your authentication.'**
  String get enterOneTimePassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get enterPassword;

  /// No description provided for @enterRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your recovery code.'**
  String get enterRecoveryCode;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username.'**
  String get enterUsername;

  /// No description provided for @enterValidationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your authentication app.'**
  String get enterValidationCode;

  /// No description provided for @failedToLoadChallenges.
  ///
  /// In en, this message translates to:
  /// **'A failure occured while fetching your challenges.'**
  String get failedToLoadChallenges;

  /// No description provided for @failedToLoadHabits.
  ///
  /// In en, this message translates to:
  /// **'A failure occured while fetching your habits.'**
  String get failedToLoadHabits;

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get failedToLoadProfile;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @females.
  ///
  /// In en, this message translates to:
  /// **'Females'**
  String get females;

  /// No description provided for @financialSituation.
  ///
  /// In en, this message translates to:
  /// **'Financial situation'**
  String get financialSituation;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @fixedDates.
  ///
  /// In en, this message translates to:
  /// **'Fixed dates'**
  String get fixedDates;

  /// No description provided for @forbiddenError.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to perform this action.'**
  String get forbiddenError;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @generateNewQrCode.
  ///
  /// In en, this message translates to:
  /// **'Generate a new QR code'**
  String get generateNewQrCode;

  /// No description provided for @generateNewRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Generate a new recovery code'**
  String get generateNewRecoveryCode;

  /// No description provided for @goToTwoFASetup.
  ///
  /// In en, this message translates to:
  /// **'Set up two-factor authentication'**
  String get goToTwoFASetup;

  /// No description provided for @habit.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habit;

  /// No description provided for @habitCategoryNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'This habit category does not exist.'**
  String get habitCategoryNotFoundError;

  /// No description provided for @habitCreated.
  ///
  /// In en, this message translates to:
  /// **'Your habit was successfully created.'**
  String get habitCreated;

  /// No description provided for @habitDailyTracking.
  ///
  /// In en, this message translates to:
  /// **'Daily Tracking'**
  String get habitDailyTracking;

  /// No description provided for @habitDailyTrackingCreated.
  ///
  /// In en, this message translates to:
  /// **'Your activity was successfully created.'**
  String get habitDailyTrackingCreated;

  /// No description provided for @habitDailyTrackingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your activity was successfully deleted.'**
  String get habitDailyTrackingDeleted;

  /// No description provided for @habitDailyTrackingNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'This activity does not exist.'**
  String get habitDailyTrackingNotFoundError;

  /// No description provided for @habitDailyTrackingUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your activity was successfully updated.'**
  String get habitDailyTrackingUpdated;

  /// No description provided for @habitDescriptionWrongSizeError.
  ///
  /// In en, this message translates to:
  /// **'Description must not be empty and less than 200 characters.'**
  String get habitDescriptionWrongSizeError;

  /// No description provided for @habitIsEmptyError.
  ///
  /// In en, this message translates to:
  /// **'A habit must be selected.'**
  String get habitIsEmptyError;

  /// No description provided for @habitName.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitName;

  /// No description provided for @habitNameWrongSizeError.
  ///
  /// In en, this message translates to:
  /// **'Habit name must not be empty and less than 100 characters.'**
  String get habitNameWrongSizeError;

  /// No description provided for @habitNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'This habit does not exist.'**
  String get habitNotFoundError;

  /// No description provided for @habitParticipationCreated.
  ///
  /// In en, this message translates to:
  /// **'You successfully joined this habit.'**
  String get habitParticipationCreated;

  /// No description provided for @habitParticipationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your participation to this habit was successfully removed.'**
  String get habitParticipationDeleted;

  /// No description provided for @habitParticipationNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'You don\'t seem to be participating to this habit.'**
  String get habitParticipationNotFoundError;

  /// No description provided for @habitParticipationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your changes were saved.'**
  String get habitParticipationUpdated;

  /// No description provided for @habitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Your habit was successfully updated.'**
  String get habitUpdated;

  /// No description provided for @habits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// No description provided for @habitsConcerned.
  ///
  /// In en, this message translates to:
  /// **'Habits Concerned'**
  String get habitsConcerned;

  /// No description provided for @habitsNotMergedError.
  ///
  /// In en, this message translates to:
  /// **'These two habits could not be merged.'**
  String get habitsNotMergedError;

  /// No description provided for @hasChildren.
  ///
  /// In en, this message translates to:
  /// **'Parent of children'**
  String get hasChildren;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello {userName}'**
  String hello(String userName);

  /// No description provided for @highSchoolOrLess.
  ///
  /// In en, this message translates to:
  /// **'High school or less'**
  String get highSchoolOrLess;

  /// No description provided for @highSchoolPlusFiveOrMoreYears.
  ///
  /// In en, this message translates to:
  /// **'High school + 5 years of studies or more'**
  String get highSchoolPlusFiveOrMoreYears;

  /// No description provided for @highSchoolPlusOneOrTwoYears.
  ///
  /// In en, this message translates to:
  /// **'High school + 1 or 2 years of studies'**
  String get highSchoolPlusOneOrTwoYears;

  /// No description provided for @highSchoolPlusThreeOrFourYears.
  ///
  /// In en, this message translates to:
  /// **'High school + 3 or 4 years of studies'**
  String get highSchoolPlusThreeOrFourYears;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @iconEmptyError.
  ///
  /// In en, this message translates to:
  /// **'An icon is needed.'**
  String get iconEmptyError;

  /// No description provided for @iconNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Habit icon not found.'**
  String get iconNotFoundError;

  /// No description provided for @internalServerError.
  ///
  /// In en, this message translates to:
  /// **'An internal server error occurred. Please try again.'**
  String get internalServerError;

  /// No description provided for @introductionToQuestions.
  ///
  /// In en, this message translates to:
  /// **'We’re excited to have you here.\n\nTo give you the best experience and share insightful statistics with you, we have a few quick questions for you.\n\nYour honest answers will help us create meaningful, worldwide statistics.\n\nYour answers to these questions cannot reveal your identity.'**
  String get introductionToQuestions;

  /// No description provided for @invalidOneTimePasswordError.
  ///
  /// In en, this message translates to:
  /// **'Invalid one-time password. Please try again.'**
  String get invalidOneTimePasswordError;

  /// No description provided for @invalidRequestError.
  ///
  /// In en, this message translates to:
  /// **'The request you made was not accepted by the server.'**
  String get invalidRequestError;

  /// No description provided for @invalidResponseError.
  ///
  /// In en, this message translates to:
  /// **'The response from the server could not be processed.'**
  String get invalidResponseError;

  /// No description provided for @invalidUsernameOrCodeOrRecoveryCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username, one-time password, or recovery code. Please try again.'**
  String get invalidUsernameOrCodeOrRecoveryCodeError;

  /// No description provided for @invalidUsernameOrPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password. Please try again.'**
  String get invalidUsernameOrPasswordError;

  /// No description provided for @invalidUsernameOrPasswordOrRecoveryCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username, password, or recovery code. Please try again.'**
  String get invalidUsernameOrPasswordOrRecoveryCodeError;

  /// No description provided for @invalidUsernameOrRecoveryCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or recovery code. Please try again.'**
  String get invalidUsernameOrRecoveryCodeError;

  /// No description provided for @joinChallengeReachYourGoals.
  ///
  /// In en, this message translates to:
  /// **'Join Challenges,\nReach Your Goals'**
  String get joinChallengeReachYourGoals;

  /// No description provided for @joinThisChallenge.
  ///
  /// In en, this message translates to:
  /// **'Participate in this challenge'**
  String get joinThisChallenge;

  /// No description provided for @joinedByXPeople.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, zero {Joined by nobody yet} one {Joined by {count} person} other {Joined by {count} people}}'**
  String joinedByXPeople(int count);

  /// No description provided for @joinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined on: {startDate}'**
  String joinedOn(String startDate);

  /// No description provided for @jumpOnTop.
  ///
  /// In en, this message translates to:
  /// **'Jump to Top'**
  String get jumpOnTop;

  /// No description provided for @keepRecoveryCodeSafe.
  ///
  /// In en, this message translates to:
  /// **'Please keep this recovery code safe.\n\nIt is necessary if you lose your password or access to your 2FA application.'**
  String get keepRecoveryCodeSafe;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lastActivity.
  ///
  /// In en, this message translates to:
  /// **'Last activity:'**
  String get lastActivity;

  /// No description provided for @lastActivityDate.
  ///
  /// In en, this message translates to:
  /// **'Last activity date:'**
  String get lastActivityDate;

  /// No description provided for @lastActivityDays.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, one {{count} day ago} other {{count} days ago}}'**
  String lastActivityDays(int count);

  /// No description provided for @lastActivityHours.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, one {{count} hour ago} other {{count} hours ago}}'**
  String lastActivityHours(int count);

  /// No description provided for @lastActivityMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, one {{count} minute ago} other {{count} minutes ago}}'**
  String lastActivityMinutes(int count);

  /// No description provided for @lastActivityMonths.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, one {{count} month ago} other {{count} months ago}}'**
  String lastActivityMonths(int count);

  /// No description provided for @lastActivitySeconds.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0 {Just now} one {{count} second ago} other {{count} seconds ago}}'**
  String lastActivitySeconds(int count);

  /// No description provided for @lastActivityYears.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, one {{count} year ago} other {{count} years ago}}'**
  String lastActivityYears(int count);

  /// No description provided for @levelOfEducation.
  ///
  /// In en, this message translates to:
  /// **'Level of education'**
  String get levelOfEducation;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @likedMessages.
  ///
  /// In en, this message translates to:
  /// **'Liked Messages'**
  String get likedMessages;

  /// No description provided for @livesInUrbanArea.
  ///
  /// In en, this message translates to:
  /// **'Living in urban area'**
  String get livesInUrbanArea;

  /// No description provided for @livingInRuralArea.
  ///
  /// In en, this message translates to:
  /// **'Rural area'**
  String get livingInRuralArea;

  /// No description provided for @livingInUrbanArea.
  ///
  /// In en, this message translates to:
  /// **'Urban area'**
  String get livingInUrbanArea;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @loginSuccessful.
  ///
  /// In en, this message translates to:
  /// **'You successfully logged in.'**
  String get loginSuccessful;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'You successfully logged out.'**
  String get logoutSuccessful;

  /// No description provided for @longName.
  ///
  /// In en, this message translates to:
  /// **'Long name'**
  String get longName;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @males.
  ///
  /// In en, this message translates to:
  /// **'Males'**
  String get males;

  /// No description provided for @markChallengeAsFinished.
  ///
  /// In en, this message translates to:
  /// **'You arrived at the end of this challenge, congratulations!\nMark it as finished to do it again later without losing the details of this participation.'**
  String get markChallengeAsFinished;

  /// No description provided for @markedAsFinishedChallenges.
  ///
  /// In en, this message translates to:
  /// **'Finished challenges'**
  String get markedAsFinishedChallenges;

  /// No description provided for @mergeHabit.
  ///
  /// In en, this message translates to:
  /// **'Merge Habit'**
  String get mergeHabit;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @messageDeletedError.
  ///
  /// In en, this message translates to:
  /// **'This message has been deleted.'**
  String get messageDeletedError;

  /// No description provided for @messageNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Message not found.'**
  String get messageNotFoundError;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @messagesAreEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Messages are end-to-end encrypted.\nNo one outside of this chat, not even our team, can read them.'**
  String get messagesAreEncrypted;

  /// No description provided for @missingDateTimeError.
  ///
  /// In en, this message translates to:
  /// **'The date can\'t be left empty.'**
  String get missingDateTimeError;

  /// No description provided for @newDiscussion.
  ///
  /// In en, this message translates to:
  /// **'New Discussion'**
  String get newDiscussion;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noAccountCreateOne.
  ///
  /// In en, this message translates to:
  /// **'No account? Create one here.'**
  String get noAccountCreateOne;

  /// No description provided for @noActivityRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded yet.'**
  String get noActivityRecordedYet;

  /// No description provided for @noAnswer.
  ///
  /// In en, this message translates to:
  /// **'I prefer to not answer'**
  String get noAnswer;

  /// No description provided for @noAnswerForThisMessageYet.
  ///
  /// In en, this message translates to:
  /// **'No answer for this message yet.'**
  String get noAnswerForThisMessageYet;

  /// No description provided for @noChallengeDailyTrackingYet.
  ///
  /// In en, this message translates to:
  /// **'No daily objectives set yet.'**
  String get noChallengeDailyTrackingYet;

  /// No description provided for @noChallengesForHabitYet.
  ///
  /// In en, this message translates to:
  /// **'No challenges yet.\nCreate the first challenge for this habit!'**
  String get noChallengesForHabitYet;

  /// No description provided for @noChallengesYet.
  ///
  /// In en, this message translates to:
  /// **'You do not have challenges yet.'**
  String get noChallengesYet;

  /// No description provided for @noConcernedHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'There are no concerned habits in this challenge yet.'**
  String get noConcernedHabitsYet;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'We\'re currently unable to connect to our servers. Please check your connection or try again shortly.'**
  String get noConnection;

  /// No description provided for @noContent.
  ///
  /// In en, this message translates to:
  /// **'No content to display'**
  String get noContent;

  /// No description provided for @noDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'No device information to display'**
  String get noDeviceInfo;

  /// No description provided for @noDevices.
  ///
  /// In en, this message translates to:
  /// **'No device to display'**
  String get noDevices;

  /// No description provided for @noDiscussionsForChallengeYet.
  ///
  /// In en, this message translates to:
  /// **'No discussions yet.\nCreate the first discussion for this challenge!'**
  String get noDiscussionsForChallengeYet;

  /// No description provided for @noDiscussionsForHabitYet.
  ///
  /// In en, this message translates to:
  /// **'No discussions yet.\nCreate the first discussion for this habit!'**
  String get noDiscussionsForHabitYet;

  /// No description provided for @noEmailOfIdentifiableDataRequired.
  ///
  /// In en, this message translates to:
  /// **'No email or identifiable data required'**
  String get noEmailOfIdentifiableDataRequired;

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'You do not have habits yet.'**
  String get noHabitsYet;

  /// No description provided for @noLikedMessages.
  ///
  /// In en, this message translates to:
  /// **'You did not like any message yet.'**
  String get noLikedMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'There are no message yet in this discussion.'**
  String get noMessagesYet;

  /// No description provided for @noNotification.
  ///
  /// In en, this message translates to:
  /// **'You do not have notifications yet.'**
  String get noNotification;

  /// No description provided for @noPrivateDiscussionsYet.
  ///
  /// In en, this message translates to:
  /// **'You do not have any private discussion yet.'**
  String get noPrivateDiscussionsYet;

  /// No description provided for @noRecoveryCodeAvailable.
  ///
  /// In en, this message translates to:
  /// **'No recovery code available.'**
  String get noRecoveryCodeAvailable;

  /// No description provided for @noReportedMessages.
  ///
  /// In en, this message translates to:
  /// **'You did not report any message yet.'**
  String get noReportedMessages;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// No description provided for @noWrittenMessages.
  ///
  /// In en, this message translates to:
  /// **'You did not write any message yet.'**
  String get noWrittenMessages;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @noteWithNote.
  ///
  /// In en, this message translates to:
  /// **'Note:'**
  String get noteWithNote;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @numberOfDaysToRepeatThisObjective.
  ///
  /// In en, this message translates to:
  /// **'Number of days to repeat this objective'**
  String get numberOfDaysToRepeatThisObjective;

  /// No description provided for @numberOfParticipantsInChallenge.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {No one participates in this challenge.} one {{count} person participates in this challenge.} other {{count} people participate in this challenge.}}'**
  String numberOfParticipantsInChallenge(int count);

  /// No description provided for @numberOfParticipantsInChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Number of participants'**
  String get numberOfParticipantsInChallengeTitle;

  /// No description provided for @numberOfParticipantsInHabit.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {No one participates in this habit.} one {{count} person participates in this habit.} other {{count} people participate in this habit.}}'**
  String numberOfParticipantsInHabit(int count);

  /// No description provided for @numberOfParticipantsInHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Number of participants'**
  String get numberOfParticipantsInHabitTitle;

  /// No description provided for @ongoingChallenges.
  ///
  /// In en, this message translates to:
  /// **'Ongoing challenges'**
  String get ongoingChallenges;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @otherChallenges.
  ///
  /// In en, this message translates to:
  /// **'Other challenges'**
  String get otherChallenges;

  /// No description provided for @participateAgain.
  ///
  /// In en, this message translates to:
  /// **'Participate again'**
  String get participateAgain;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordForgotten.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get passwordForgotten;

  /// No description provided for @passwordMustBeChangedError.
  ///
  /// In en, this message translates to:
  /// **'You need to change your password to log in.'**
  String get passwordMustBeChangedError;

  /// No description provided for @passwordNotComplexEnough.
  ///
  /// In en, this message translates to:
  /// **'Your password must contain at least a letter, a digit, and a special character.'**
  String get passwordNotComplexEnough;

  /// No description provided for @passwordNotExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Your password is not expired, so it cannot be changed this way.'**
  String get passwordNotExpiredError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In en, this message translates to:
  /// **'Your password must be at least 8 characters long.'**
  String get passwordTooShortError;

  /// No description provided for @passwordUpdateSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Your password was successfully updated.'**
  String get passwordUpdateSuccessful;

  /// No description provided for @peopleWithChildren.
  ///
  /// In en, this message translates to:
  /// **'People with children'**
  String get peopleWithChildren;

  /// No description provided for @peopleWithoutChildren.
  ///
  /// In en, this message translates to:
  /// **'People without children'**
  String get peopleWithoutChildren;

  /// No description provided for @personalizedNotificationsToStayOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Personalized notifications to stay on track'**
  String get personalizedNotificationsToStayOnTrack;

  /// No description provided for @pleaseLoginOrSignUp.
  ///
  /// In en, this message translates to:
  /// **'Please log in or sign up to continue.'**
  String get pleaseLoginOrSignUp;

  /// No description provided for @poor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get poor;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyMarkdown.
  ///
  /// In en, this message translates to:
  /// **'# Privacy Policy\n\n**Effective Date:** April 5, 2025  \n**Last Updated:** April 5, 2025\n\nWelcome to **ReallyStick**, a social habit-tracking platform that enables users to track their daily progress, join challenges, and engage in public or private discussions — all while maintaining control over their personal data.\n\n## 1. Information We Collect\n\n### Required Data\n- Username\n- Password (hashed securely)\n- Recovery Code\n- Device Information (OS, platform, type)\n- IP Address\n- Session Tokens\n\n### Optional Demographics\n- Continent\n- Country\n- Age category\n- Gender\n- Level of study\n- Level of wealth\n- Employment status\n\n## 2. Private Messaging & Encryption\n\n- End-to-end encrypted private messages\n- Your private key is stored only on your device\n- We cannot read your private messages\n\n## 3. How We Use Your Data\n\nWe use your data to:\n- Provide app functionality\n- Manage device sessions\n- Generate anonymous analytics\n- Send push notifications (via Google Firebase)\n- Monitor abuse and maintain security\n\nWe do **not** sell or share your data for advertising.\n\n## 4. Data Sharing\n\nOnly external service:  \n- Google Firebase – used for push notifications. Firebase may collect device identifiers and token information to deliver messages. We do not share personally identifiable data with Firebase.\n\n## 5. Public Interactions\n\n- Only usernames are shown publicly\n- Public messages can be reported and moderated\n\n## 6. Data Retention & Deletion\n\nUsers can delete their account and all related data from their profile page.\n\n## 7. Security Measures\n\n- Hashed passwords\n- Local token storage\n- End-to-end encryption\n- IP logging for abuse prevention\n\n## 8. Anonymity & Identity\n\n- No email or real names required\n- Accounts are pseudonymous\n\n## 9. Children’s Privacy\n\nOur app is open to all users, but parental consent may be required depending on your local laws.\n\n## 10. User Rights (GDPR)\n\n- Access your data\n- Delete your data\n- Opt out of optional data fields\n\n## 11. Policy Changes\n\nWe may update this Privacy Policy. You’ll be notified in-app if we make major changes.\n\n## 12. Contact Us\n\nUse the in-app contact form\n\nFor privacy-related inquiries, you may also email us at: **[support@reallystick.com](support@reallystick.com)**'**
  String get privacyPolicyMarkdown;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @profileUpdateSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Profile information saved.'**
  String get profileUpdateSuccessful;

  /// No description provided for @publicMessageDeletionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Your message was successfully deleted.'**
  String get publicMessageDeletionSuccessful;

  /// No description provided for @publicMessageReportCreationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Your report was succesfully sent.'**
  String get publicMessageReportCreationSuccessful;

  /// No description provided for @qrCodeSecretKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'QR code secret key copied to clipboard.'**
  String get qrCodeSecretKeyCopied;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityOfSet.
  ///
  /// In en, this message translates to:
  /// **'Quantity of set'**
  String get quantityOfSet;

  /// No description provided for @quantityOfSetIsNegativeError.
  ///
  /// In en, this message translates to:
  /// **'The quantity of set can\'t be negative.'**
  String get quantityOfSetIsNegativeError;

  /// No description provided for @quantityOfSetIsNullError.
  ///
  /// In en, this message translates to:
  /// **'The quantity of set can\'t be null.'**
  String get quantityOfSetIsNullError;

  /// No description provided for @quantityOfSetWithQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity of set: {quantity}'**
  String quantityOfSetWithQuantity(int quantity);

  /// No description provided for @quantityPerSet.
  ///
  /// In en, this message translates to:
  /// **'Quantity per set'**
  String get quantityPerSet;

  /// No description provided for @quantityPerSetIsNegativeError.
  ///
  /// In en, this message translates to:
  /// **'The quantity can\'t be negative.'**
  String get quantityPerSetIsNegativeError;

  /// No description provided for @quantityPerSetIsNullError.
  ///
  /// In en, this message translates to:
  /// **'The quantity can\'t be empty.'**
  String get quantityPerSetIsNullError;

  /// No description provided for @quantityPerSetWithQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity per set: {quantity}'**
  String quantityPerSetWithQuantity(int quantity);

  /// No description provided for @quantityWithQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity: {quantity}'**
  String quantityWithQuantity(int quantity);

  /// No description provided for @questionActivity.
  ///
  /// In en, this message translates to:
  /// **'What is your current activity?'**
  String get questionActivity;

  /// No description provided for @questionAge.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get questionAge;

  /// No description provided for @questionFinancialSituation.
  ///
  /// In en, this message translates to:
  /// **'How would you describe your financial situation?'**
  String get questionFinancialSituation;

  /// No description provided for @questionGender.
  ///
  /// In en, this message translates to:
  /// **'Are you a male or female?'**
  String get questionGender;

  /// No description provided for @questionHasChildren.
  ///
  /// In en, this message translates to:
  /// **'Do you have children?'**
  String get questionHasChildren;

  /// No description provided for @questionLevelOfEducation.
  ///
  /// In en, this message translates to:
  /// **'What is your level of education?'**
  String get questionLevelOfEducation;

  /// No description provided for @questionLivingInUrbanArea.
  ///
  /// In en, this message translates to:
  /// **'Are you living in an urban area?'**
  String get questionLivingInUrbanArea;

  /// No description provided for @questionLocation.
  ///
  /// In en, this message translates to:
  /// **'Where do you live?'**
  String get questionLocation;

  /// No description provided for @questionRelationStatus.
  ///
  /// In en, this message translates to:
  /// **'Are you now in a relation?'**
  String get questionRelationStatus;

  /// No description provided for @questionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'Your answers were saved. We thank you!'**
  String get questionsAnswered;

  /// No description provided for @quitThisChallenge.
  ///
  /// In en, this message translates to:
  /// **'Quit this challenge'**
  String get quitThisChallenge;

  /// No description provided for @quitThisHabit.
  ///
  /// In en, this message translates to:
  /// **'Quit this habit'**
  String get quitThisHabit;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @recipientMissingPublicKey.
  ///
  /// In en, this message translates to:
  /// **'This recipient does not have secret keys yet.'**
  String get recipientMissingPublicKey;

  /// No description provided for @recoverAccount.
  ///
  /// In en, this message translates to:
  /// **'Recover Account'**
  String get recoverAccount;

  /// No description provided for @recoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCode;

  /// No description provided for @recoveryCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Recovery code copied to clipboard.'**
  String get recoveryCodeCopied;

  /// No description provided for @recoveryCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your recovery code can be used if you forgot your password.\n\nPlease, keep it confidential.\n\nIf you forgot it, you can generate a new one.\n\nBe aware that this will deactivate the current recovery code.'**
  String get recoveryCodeDescription;

  /// No description provided for @refreshTokenExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get refreshTokenExpiredError;

  /// No description provided for @regenerateQrCode.
  ///
  /// In en, this message translates to:
  /// **'Regenerate QR code'**
  String get regenerateQrCode;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @relatedChallenges.
  ///
  /// In en, this message translates to:
  /// **'Related Challenges'**
  String get relatedChallenges;

  /// No description provided for @relationshipStatus.
  ///
  /// In en, this message translates to:
  /// **'Relationship status'**
  String get relationshipStatus;

  /// No description provided for @relationshipStatusCouple.
  ///
  /// In en, this message translates to:
  /// **'In a relation'**
  String get relationshipStatusCouple;

  /// No description provided for @relationshipStatusSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get relationshipStatusSingle;

  /// No description provided for @repeatOnMultipleDaysAfter.
  ///
  /// In en, this message translates to:
  /// **'Repeat on several days after this one'**
  String get repeatOnMultipleDaysAfter;

  /// No description provided for @repetitionNumberIsNegativeError.
  ///
  /// In en, this message translates to:
  /// **'The repetition number can\'t be negative.'**
  String get repetitionNumberIsNegativeError;

  /// No description provided for @repetitionNumberIsNullError.
  ///
  /// In en, this message translates to:
  /// **'The repetition number can\'t be null.'**
  String get repetitionNumberIsNullError;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replyTo.
  ///
  /// In en, this message translates to:
  /// **'Reply to {user}...'**
  String replyTo(String user);

  /// No description provided for @reportMessage.
  ///
  /// In en, this message translates to:
  /// **'Report Message'**
  String get reportMessage;

  /// No description provided for @reportedMessages.
  ///
  /// In en, this message translates to:
  /// **'Reported Messages'**
  String get reportedMessages;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @reviewHabit.
  ///
  /// In en, this message translates to:
  /// **'Review habit'**
  String get reviewHabit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saveHabit.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveHabit;

  /// No description provided for @searchChallenges.
  ///
  /// In en, this message translates to:
  /// **'Search Challenges'**
  String get searchChallenges;

  /// No description provided for @searchHabits.
  ///
  /// In en, this message translates to:
  /// **'Search Habits'**
  String get searchHabits;

  /// No description provided for @searchUser.
  ///
  /// In en, this message translates to:
  /// **'Search User'**
  String get searchUser;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @selectUnits.
  ///
  /// In en, this message translates to:
  /// **'Select units of measure for this habit'**
  String get selectUnits;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password.'**
  String get setNewPassword;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareChallengeSubject.
  ///
  /// In en, this message translates to:
  /// **'Join a challenge'**
  String get shareChallengeSubject;

  /// No description provided for @shareChallengeText.
  ///
  /// In en, this message translates to:
  /// **'Hey! This challenge could be interesting for you: {link}'**
  String shareChallengeText(String link);

  /// No description provided for @shortName.
  ///
  /// In en, this message translates to:
  /// **'Short name'**
  String get shortName;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @startHabitShort.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startHabitShort;

  /// No description provided for @startTrackingThisHabit.
  ///
  /// In en, this message translates to:
  /// **'Start tracking this habit'**
  String get startTrackingThisHabit;

  /// No description provided for @startsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts on: {startDate}'**
  String startsOn(String startDate);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @tapForMoreDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for more details'**
  String get tapForMoreDetails;

  /// No description provided for @tapToSeeLess.
  ///
  /// In en, this message translates to:
  /// **'Tap to see less'**
  String get tapToSeeLess;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @termsOfUseMarkdown.
  ///
  /// In en, this message translates to:
  /// **'# Terms of Use\n\n**Effective Date:** April 5, 2025  \n**Last Updated:** April 5, 2025\n\nWelcome to **ReallyStick**, a social habit-tracking platform designed to help you track and improve your daily habits. By accessing or using the app, you agree to be bound by the following Terms of Use. If you do not agree with these terms, please do not use the app.\n\n## 1. User Accounts\n\nTo use certain features of the app, you must create an account. You agree to:\n- Provide accurate and complete information during the registration process.\n- Keep your account information (username, password, recovery code) confidential.\n- Notify us immediately if you suspect unauthorized access to your account.\n\nYou are responsible for all activities that occur under your account, including any data shared or actions taken through your account.\n\n## 2. Use of the App\n\nYou agree to use **ReallyStick** only for lawful purposes and in accordance with these Terms of Use. You shall not:\n- Violate any applicable laws or regulations.\n- Post, share, or engage in any activity that is harmful, offensive, or illegal.\n- Use the app to send unsolicited messages or spam.\n- Attempt to hack, damage, or gain unauthorized access to the app or its features.\n\nWe reserve the right to suspend or terminate your account if you violate these terms.\n\n## 3. Privacy and Data Collection\n\nYour privacy is important to us. We collect certain data as outlined in our **Privacy Policy**. By using the app, you consent to the collection and use of your data in accordance with our Privacy Policy.\n\n## 4. Content and Ownership\n\n- All content provided by **ReallyStick** (including the app, website, and any related materials) is owned by us or our licensors and is protected by copyright, trademark, and other intellectual property laws.\n- You may not copy, modify, distribute, or create derivative works of any content without our permission.\n- You retain ownership of any content you post within the app, but by posting content, you grant us a license to use, display, and distribute that content within the app and for promotional purposes.\n\n## 5. User-Generated Content\n\nYou are responsible for the content you post or share on **ReallyStick**. This includes text, images, and any other media. You agree not to post:\n- Content that is harmful, harassing, offensive, or discriminatory.\n- Content that infringes on the intellectual property rights of others.\n- Content that violates any applicable laws.\n\nWe reserve the right to remove any content that violates these terms.\n\n## 6. Push Notifications\n\nWe may send you push notifications for updates, reminders, and important app-related information. You can manage or disable these notifications in the app’s settings.\n\n## 7. Termination\n\nWe reserve the right to suspend or terminate your access to **ReallyStick** at any time, for any reason, including if you violate these Terms of Use. Upon termination, your account will be deleted, and you will lose access to the app.\n\n## 8. Disclaimers\n\n- The app is provided \"as-is\" without any warranties of any kind, either express or implied.\n- We do not guarantee that the app will be error-free, secure, or available at all times.\n\n## 9. Limitation of Liability\n\nTo the fullest extent permitted by law, we are not liable for any damages arising from your use or inability to use **ReallyStick**, including but not limited to data loss, system errors, or any other indirect or consequential damages.\n\n## 10. Indemnification\n\nYou agree to indemnify, defend, and hold harmless **ReallyStick** and its affiliates from any claims, damages, liabilities, and expenses (including legal fees) arising from your use of the app, your violation of these Terms of Use, or any content you post or share on the app.\n\n## 11. Governing Law\n\nThese Terms of Use are governed by the laws of the jurisdiction in which you reside. Any disputes will be resolved in the appropriate courts in your region.\n\n## 12. Changes to the Terms\n\nWe may update these Terms of Use from time to time. If we make any material changes, we will notify you within the app. The most current version of these terms will always be available in the app.\n\n## 13. Contact Us\n\nIf you have any questions or concerns regarding these Terms of Use, please contact us using the in-app contact form.'**
  String get termsOfUseMarkdown;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @timeWithTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String timeWithTime(String time);

  /// No description provided for @topActivityCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get topActivityCardTitle;

  /// No description provided for @topAgesCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Age categories'**
  String get topAgesCardTitle;

  /// No description provided for @topCountriesCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get topCountriesCardTitle;

  /// No description provided for @topFinancialSituationsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial situation'**
  String get topFinancialSituationsCardTitle;

  /// No description provided for @topGenderCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get topGenderCardTitle;

  /// No description provided for @topHasChildrenCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get topHasChildrenCardTitle;

  /// No description provided for @topLevelsOfEducationCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Level of education'**
  String get topLevelsOfEducationCardTitle;

  /// No description provided for @topLivesInUrbanAreaCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Living area'**
  String get topLivesInUrbanAreaCardTitle;

  /// No description provided for @topRegionsCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get topRegionsCardTitle;

  /// No description provided for @topRelationshipStatusesCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Relationship status'**
  String get topRelationshipStatusesCardTitle;

  /// No description provided for @twoFA.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get twoFA;

  /// No description provided for @twoFAInvitation.
  ///
  /// In en, this message translates to:
  /// **'Security and privacy are our top priorities.\n\nPlease set up two-factor authentication to protect your account from brute-force attacks.'**
  String get twoFAInvitation;

  /// No description provided for @twoFAIsWellSetup.
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication is successfully set up for your account.'**
  String get twoFAIsWellSetup;

  /// No description provided for @twoFAScanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your authentication app.'**
  String get twoFAScanQrCode;

  /// No description provided for @twoFASecretKey.
  ///
  /// In en, this message translates to:
  /// **'Your QR code secret key is: {secretKey}'**
  String twoFASecretKey(String secretKey);

  /// No description provided for @twoFASetup.
  ///
  /// In en, this message translates to:
  /// **'Enable two-factor authentication to secure your account.'**
  String get twoFASetup;

  /// No description provided for @twoFactorAuthenticationNotEnabledError.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication is not enabled for your account.'**
  String get twoFactorAuthenticationNotEnabledError;

  /// No description provided for @unableToLoadRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Unable to load the recovery code.'**
  String get unableToLoadRecoveryCode;

  /// No description provided for @unauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to perform this action.'**
  String get unauthorizedError;

  /// No description provided for @unblockThisUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock this user'**
  String get unblockThisUser;

  /// No description provided for @unemployed.
  ///
  /// In en, this message translates to:
  /// **'Unemployed'**
  String get unemployed;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @unitNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'This unit was not found.'**
  String get unitNotFoundError;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unknownError;

  /// No description provided for @updateChallenge.
  ///
  /// In en, this message translates to:
  /// **'Update challenge'**
  String get updateChallenge;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current and new password.'**
  String get updatePassword;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'A new version is required to continue using the app.'**
  String get updateRequired;

  /// No description provided for @userAlreadyExistingError.
  ///
  /// In en, this message translates to:
  /// **'A user with this username already exists. Please choose another.'**
  String get userAlreadyExistingError;

  /// No description provided for @userNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'User not found.'**
  String get userNotFoundError;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameNotRespectingRulesError.
  ///
  /// In en, this message translates to:
  /// **'Your username must follow these rules:\n - Start and end with a letter or digit\n - Allowed special characters are . _ -\n - No consecutive special characters'**
  String get usernameNotRespectingRulesError;

  /// No description provided for @usernameWrongSizeError.
  ///
  /// In en, this message translates to:
  /// **'Username length must be between 3 and 20 characters.'**
  String get usernameWrongSizeError;

  /// No description provided for @validationCode.
  ///
  /// In en, this message translates to:
  /// **'Validation code'**
  String get validationCode;

  /// No description provided for @validationCodeCorrect.
  ///
  /// In en, this message translates to:
  /// **'Your validation code is correct!'**
  String get validationCodeCorrect;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @wealthy.
  ///
  /// In en, this message translates to:
  /// **'Wealthy'**
  String get wealthy;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @weightIsNegativeError.
  ///
  /// In en, this message translates to:
  /// **'Weight can\'t be negative.'**
  String get weightIsNegativeError;

  /// No description provided for @weightUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight Unit'**
  String get weightUnit;

  /// No description provided for @weightWithQuantity.
  ///
  /// In en, this message translates to:
  /// **'Weight: {quantity} {unit}'**
  String weightWithQuantity(int quantity, String unit);

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome on ReallyStick'**
  String get welcome;

  /// No description provided for @whatIsThis.
  ///
  /// In en, this message translates to:
  /// **'What is this?'**
  String get whatIsThis;

  /// No description provided for @worker.
  ///
  /// In en, this message translates to:
  /// **'Worker'**
  String get worker;

  /// No description provided for @writeTo.
  ///
  /// In en, this message translates to:
  /// **'Write to {user}...'**
  String writeTo(String user);

  /// No description provided for @writtenMessages.
  ///
  /// In en, this message translates to:
  /// **'Written Messages'**
  String get writtenMessages;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @youAreNotAlone.
  ///
  /// In en, this message translates to:
  /// **'You are not alone.\nTalk. Share. Grow.'**
  String get youAreNotAlone;

  /// No description provided for @youAreNotTheCreatorOfThisChallenge.
  ///
  /// In en, this message translates to:
  /// **'You are not the creator of this challenge.'**
  String get youAreNotTheCreatorOfThisChallenge;

  /// No description provided for @youBlockedThisUser.
  ///
  /// In en, this message translates to:
  /// **'You blocked this user.'**
  String get youBlockedThisUser;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr', 'it', 'pt', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
