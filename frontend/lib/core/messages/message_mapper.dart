import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/messages/message.dart';

String getTranslatedMessage(BuildContext context, Message message) {
  final localizations = AppLocalizations.of(context)!;

  if (message is ErrorMessage) {
    switch (message.messageKey) {
      // Generic
      case 'unknown_error':
        return localizations.unknownError;
      case 'internalServerError':
        return localizations.internalServerError;
      case 'invalidRequestError':
        return localizations.invalidRequestError;
      case 'invalidResponseError':
        return localizations.invalidResponseError;
      case 'forbiddenError':
        return localizations.forbiddenError;
      case 'unauthorizedError':
        return localizations.unauthorizedError;

      // Auth
      case 'invalidUsernameOrCodeOrRecoveryCodeError':
        return localizations.invalidUsernameOrCodeOrRecoveryCodeError;
      case 'invalidUsernameOrRecoveryCodeError':
        return localizations.invalidUsernameOrRecoveryCodeError;
      case 'invalidUsernameOrPasswordOrRecoveryCodeError':
        return localizations.invalidUsernameOrPasswordOrRecoveryCodeError;
      case 'userNotFoundError':
        return localizations.userNotFoundError;
      case 'invalidOneTimePasswordError':
        return localizations.invalidOneTimePasswordError;
      case 'invalidUsernameOrPasswordError':
        return localizations.invalidUsernameOrPasswordError;
      case 'passwordMustBeChangedError':
        return localizations.passwordMustBeChangedError;
      case 'passwordTooShortError':
        return localizations.passwordTooShortError;
      case 'passwordNotComplexEnough':
        return localizations.passwordNotComplexEnough;
      case 'refreshTokenExpiredError':
        return localizations.refreshTokenExpiredError;
      case 'twoFactorAuthenticationNotEnabledError':
        return localizations.twoFactorAuthenticationNotEnabledError;
      case 'userAlreadyExistingError':
        return localizations.userAlreadyExistingError;
      case 'usernameNotRespectingRulesError':
        return localizations.usernameNotRespectingRulesError;
      case 'usernameWrongSizeError':
        return localizations.usernameWrongSizeError;

      // Habits
      case 'habitIsEmptyError':
        return localizations.habitIsEmptyError;
      case 'habitNotFoundError':
        return localizations.habitNotFoundError;
      case 'habitParticipationNotFoundError':
        return localizations.habitParticipationNotFoundError;
      case 'habitCategoryNotFoundError':
        return localizations.habitCategoryNotFoundError;
      case 'habitDailyTrackingNotFoundError':
        return localizations.habitDailyTrackingNotFoundError;
      case 'habitShortNameWrongSizeError':
        return localizations.habitShortNameWrongSizeError;
      case 'habitLongNameWrongSizeError':
        return localizations.habitLongNameWrongSizeError;
      case 'habitDescriptionWrongSizeError':
        return localizations.habitDescriptionWrongSizeError;
      case 'iconNotFoundError':
        return localizations.iconNotFoundError;
      case 'iconEmptyError':
        return localizations.iconEmptyError;
      case 'habitsNotMergedError':
        return localizations.habitsNotMergedError;
      case 'unitNotFoundError':
        return localizations.unitNotFoundError;
      case 'quantityOfSetIsNullError':
        return localizations.quantityOfSetIsNullError;
      case 'quantityPerSetIsNullError':
        return localizations.quantityPerSetIsNullError;
      case 'quantityOfSetIsNegativeError':
        return localizations.quantityOfSetIsNegativeError;
      case 'quantityPerSetIsNegativeError':
        return localizations.quantityPerSetIsNegativeError;
      case 'dateTimeIsInTheFutureError':
        return localizations.dateTimeIsInTheFutureError;
      case 'missingDateTimeError':
        return localizations.missingDateTimeError;
      case 'weightIsNegativeError':
        return localizations.weightIsNegativeError;
      case 'atLeastOneTranslationNeededError':
        return localizations.atLeastOneTranslationNeededError;
      case 'dateTimeIsInThePastError':
        return localizations.dateTimeIsInThePastError;
      case 'challengeNameWrongSizeError':
        return localizations.challengeNameWrongSizeError;
      case 'challengeDailyTrackingNotFoundError':
        return localizations.challengeDailyTrackingNotFoundError;
      case 'challengeParticipationNotFoundError':
        return localizations.challengeParticipationNotFoundError;
      case 'challengeNotFoundError':
        return localizations.challengeNotFoundError;

      // Profile
      case 'passwordNotExpiredError':
        return localizations.passwordNotExpiredError;

      default:
        return localizations.defaultError;
    }
  } else if (message is SuccessMessage) {
    switch (message.messageKey) {
      // Auth
      case 'loginSuccessful':
        return localizations.loginSuccessful;
      case 'logoutSuccessful':
        return localizations.logoutSuccessful;
      case 'validationCodeCorrect':
        return localizations.validationCodeCorrect;

      // Habits
      case 'habitCreated':
        return localizations.habitCreated;
      case 'habitUpdated':
        return localizations.habitUpdated;
      case 'habitDailyTrackingCreated':
        return localizations.habitDailyTrackingCreated;
      case 'habitDailyTrackingUpdated':
        return localizations.habitDailyTrackingUpdated;
      case 'habitDailyTrackingDeleted':
        return localizations.habitDailyTrackingDeleted;
      case 'habitParticipationDeleted':
        return localizations.habitParticipationDeleted;
      case 'habitParticipationUpdated':
        return localizations.habitParticipationUpdated;
      case 'habitParticipationCreated':
        return localizations.habitParticipationCreated;

      // Profile
      case 'passwordUpdateSuccessful':
        return localizations.passwordUpdateSuccessful;
      case 'profileUpdateSuccessful':
        return localizations.profileUpdateSuccessful;
      case 'questionsAnswered':
        return localizations.questionsAnswered;
      case 'accountDeletionSuccessful':
        return localizations.accountDeletionSuccessful;

      default:
        return localizations.defaultError;
    }
  } else if (message is InfoMessage) {
    switch (message.messageKey) {
      // Auth
      case 'recoveryCodesCopied':
        return localizations.recoveryCodesCopied;
      case 'qrCodeSecretKeyCopied':
        return localizations.qrCodeSecretKeyCopied;

      default:
        return localizations.defaultError;
    }
  } else {
    return localizations.defaultError;
  }
}
