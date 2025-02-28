import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_bloc.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge/challenge_states.dart';
import 'package:reallystick/features/challenges/presentation/helpers/statistics.dart';
import 'package:reallystick/features/habits/domain/entities/analytics_card_info.dart';
import 'package:reallystick/features/habits/presentation/widgets/analytics_card_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class AnalyticsCarouselWidget extends StatelessWidget {
  final Color challengeColor;
  final String challengeId;

  const AnalyticsCarouselWidget({
    required this.challengeColor,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    final challengeState = context.watch<ChallengeBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;

    if (challengeState is ChallengesLoaded &&
        profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;
      final challengeStatistic =
          challengeState.challengeStatistics[challengeId];

      List<AnalyticsCardInfo> analyticsCards = [];

      if (challengeStatistic != null) {
        final topAgesText = computeTopAgesText(context, challengeStatistic);
        final topCountriesText =
            computeTopCountriesText(context, challengeStatistic);
        final topRegionsText =
            computeTopRegionsText(context, challengeStatistic);
        final topHasChildrenText =
            computeTopHasChildrenText(context, challengeStatistic);
        final topLivesInUrbanAreaText =
            computeTopLivesInUrbanAreaText(context, challengeStatistic);
        final topGenderText = computeTopGenderText(context, challengeStatistic);
        final topActivitiesText =
            computeTopActivitiesText(context, challengeStatistic);
        final topFinancialSituationsText =
            computeTopFinancialSituationsText(context, challengeStatistic);
        final topRelationshipStatusesText =
            computeTopRelationshipStatusesText(context, challengeStatistic);
        final topLevelsOfEducationText =
            computeTopLevelsOfEducationText(context, challengeStatistic);

        analyticsCards.add(
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!.topAgesCardTitle,
            icon: Icons.cake,
            text: topAgesText,
          ),
        );
        analyticsCards.add(
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!.topCountriesCardTitle,
            icon: Icons.flag,
            text: topCountriesText,
          ),
        );
        analyticsCards.add(
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!.topRegionsCardTitle,
            icon: Icons.public,
            text: topRegionsText,
          ),
        );
        analyticsCards.add(
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!.topHasChildrenCardTitle,
            icon: Icons.escalator_warning,
            text: topHasChildrenText,
          ),
        );
        analyticsCards.add(
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!.topLivesInUrbanAreaCardTitle,
            icon: Icons.location_city,
            text: topLivesInUrbanAreaText,
          ),
        );
        analyticsCards.add(
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!.topGenderCardTitle,
            icon: Icons.wc,
            text: topGenderText,
          ),
        );
        analyticsCards.add(
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!.topActivityCardTitle,
            icon: Icons.work,
            text: topActivitiesText,
          ),
        );
        analyticsCards.add(
          AnalyticsCardInfo(
            title:
                AppLocalizations.of(context)!.topFinancialSituationsCardTitle,
            icon: Icons.account_balance_wallet,
            text: topFinancialSituationsText,
          ),
        );
        analyticsCards.add(
          AnalyticsCardInfo(
            title:
                AppLocalizations.of(context)!.topRelationshipStatusesCardTitle,
            icon: Icons.favorite,
            text: topRelationshipStatusesText,
          ),
        );
        analyticsCards.add(
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!.topLevelsOfEducationCardTitle,
            icon: Icons.school,
            text: topLevelsOfEducationText,
          ),
        );

        analyticsCards.shuffle();

        analyticsCards.insert(
          0,
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!
                .numberOfParticipantsInChallengeTitle,
            icon: Icons.people,
            text: AppLocalizations.of(context)!.numberOfParticipantsInChallenge(
                challengeStatistic.participantsCount),
          ),
        );
      } else {
        analyticsCards.add(
          AnalyticsCardInfo(
            title: AppLocalizations.of(context)!.comingSoon,
            icon: Icons.info,
            text: "",
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.query_stats,
                size: 30,
                color: challengeColor,
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.analytics,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: challengeColor,
                ),
              ),
              Spacer(),
              Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: AppLocalizations.of(context)!.analyticsInfoTooltip,
                child: Icon(
                  Icons.info_outline,
                  size: 25,
                  color: challengeColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: analyticsCards.map((card) {
                return AnalyticsCardWidget(
                  key: ValueKey(card.title),
                  analyticsCardInfo: card,
                  userLocale: userLocale,
                  color: challengeColor,
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(challengeColor),
        ),
      );
    }
  }
}
