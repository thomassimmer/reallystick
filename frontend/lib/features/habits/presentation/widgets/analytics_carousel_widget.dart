import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/habits/domain/entities/analytics_card_info.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/statistics.dart';
import 'package:reallystick/features/habits/presentation/widgets/analytics_card_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class AnalyticsCarouselWidget extends StatelessWidget {
  final Color habitColor;
  final String habitId;

  const AnalyticsCarouselWidget({
    required this.habitColor,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context) {
    final habitState = context.read<HabitBloc>().state;
    final profileState = context.read<ProfileBloc>().state;

    if (habitState is HabitsLoaded && profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;
      final habitStatistic = habitState.habitStatistics[habitId];

      List<AnalyticsCardInfo> analyticsCards = [];

      if (habitStatistic != null) {
        final topAgesText = computeTopAgesText(context, habitStatistic);
        final topCountriesText =
            computeTopCountriesText(context, habitStatistic);
        final topRegionsText = computeTopRegionsText(context, habitStatistic);
        final topHasChildrenText =
            computeTopHasChildrenText(context, habitStatistic);
        final topLivesInUrbanAreaText =
            computeTopLivesInUrbanAreaText(context, habitStatistic);
        final topGenderText = computeTopGenderText(context, habitStatistic);
        final topActivitiesText =
            computeTopActivitiesText(context, habitStatistic);
        final topFinancialSituationsText =
            computeTopFinancialSituationsText(context, habitStatistic);
        final topRelationshipStatusesText =
            computeTopRelationshipStatusesText(context, habitStatistic);
        final topLevelsOfEducationText =
            computeTopLevelsOfEducationText(context, habitStatistic);

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
            title:
                AppLocalizations.of(context)!.numberOfParticipantsInHabitTitle,
            icon: Icons.people,
            text: AppLocalizations.of(context)!
                .numberOfParticipantsInHabit(habitStatistic.participantsCount),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.query_stats,
                  size: 30,
                  color: habitColor,
                ),
                SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.analytics,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: habitColor,
                  ),
                ),
                Spacer(),
                Tooltip(
                  message: AppLocalizations.of(context)!.analyticsInfoTooltip,
                  child: Icon(
                    Icons.info_outline,
                    size: 25,
                    color: habitColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
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
                  habitColor: habitColor,
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(habitColor),
        ),
      );
    }
  }
}
