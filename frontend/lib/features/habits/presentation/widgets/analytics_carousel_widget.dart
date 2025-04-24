import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/utils/preview_data.dart';
import 'package:reallystick/features/habits/domain/entities/analytics_card_info.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_bloc.dart';
import 'package:reallystick/features/habits/presentation/blocs/habit/habit_states.dart';
import 'package:reallystick/features/habits/presentation/helpers/statistics.dart';
import 'package:reallystick/features/habits/presentation/widgets/analytics_card_widget.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class AnalyticsCarouselWidget extends StatefulWidget {
  final Color habitColor;
  final String habitId;
  final bool previewMode;

  const AnalyticsCarouselWidget({
    super.key,
    required this.habitColor,
    required this.habitId,
    required this.previewMode,
  });

  @override
  State<AnalyticsCarouselWidget> createState() =>
      AnalyticsCarouselWidgetState();
}

class AnalyticsCarouselWidgetState extends State<AnalyticsCarouselWidget> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.previewMode) {
        _startSlowScroll();
      }
    });
  }

  void _startSlowScroll() {
    if (!controller.hasClients) return;

    const double scrollSpeedPerSecond = 20;
    final double maxScroll = controller.position.maxScrollExtent;
    final double currentScroll = controller.offset;
    final double distanceToScroll = maxScroll - currentScroll;

    if (distanceToScroll <= 0) return;

    final durationSeconds = distanceToScroll / scrollSpeedPerSecond;
    final duration = Duration(
      milliseconds: (durationSeconds * 1000).clamp(1, double.infinity).toInt(),
    );

    controller.animateTo(
      maxScroll,
      duration: duration,
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = widget.previewMode
        ? getProfileAuthenticatedForPreview(context)
        : context.watch<ProfileBloc>().state;
    final habitState = widget.previewMode
        ? getHabitsLoadedForPreview(context)
        : context.watch<HabitBloc>().state;

    if (habitState is HabitsLoaded && profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;
      final habitStatistic = habitState.habitStatistics[widget.habitId];

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

        if (topAgesText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title: AppLocalizations.of(context)!.topAgesCardTitle,
              icon: Icons.cake,
              text: topAgesText,
            ),
          );
        }

        if (topCountriesText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title: AppLocalizations.of(context)!.topCountriesCardTitle,
              icon: Icons.flag,
              text: topCountriesText,
            ),
          );
        }

        if (topRegionsText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title: AppLocalizations.of(context)!.topRegionsCardTitle,
              icon: Icons.public,
              text: topRegionsText,
            ),
          );
        }

        if (topHasChildrenText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title: AppLocalizations.of(context)!.topHasChildrenCardTitle,
              icon: Icons.escalator_warning,
              text: topHasChildrenText,
            ),
          );
        }

        if (topLivesInUrbanAreaText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title: AppLocalizations.of(context)!.topLivesInUrbanAreaCardTitle,
              icon: Icons.location_city,
              text: topLivesInUrbanAreaText,
            ),
          );
        }

        if (topGenderText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title: AppLocalizations.of(context)!.topGenderCardTitle,
              icon: Icons.wc,
              text: topGenderText,
            ),
          );
        }

        if (topActivitiesText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title: AppLocalizations.of(context)!.topActivityCardTitle,
              icon: Icons.work,
              text: topActivitiesText,
            ),
          );
        }

        if (topFinancialSituationsText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title:
                  AppLocalizations.of(context)!.topFinancialSituationsCardTitle,
              icon: Icons.account_balance_wallet,
              text: topFinancialSituationsText,
            ),
          );
        }

        if (topRelationshipStatusesText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title: AppLocalizations.of(context)!
                  .topRelationshipStatusesCardTitle,
              icon: Icons.favorite,
              text: topRelationshipStatusesText,
            ),
          );
        }

        if (topLevelsOfEducationText.isNotEmpty) {
          analyticsCards.add(
            AnalyticsCardInfo(
              title:
                  AppLocalizations.of(context)!.topLevelsOfEducationCardTitle,
              icon: Icons.school,
              text: topLevelsOfEducationText,
            ),
          );
        }

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
            title: "",
            icon: Icons.info,
            text: AppLocalizations.of(context)!.comingSoon,
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
                size: 20,
                color: widget.habitColor,
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.of(context)!.analytics,
                style: TextStyle(
                  fontSize: 20,
                  color: widget.habitColor,
                ),
              ),
              Spacer(),
              Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                message: AppLocalizations.of(context)!.analyticsInfoTooltip,
                child: Icon(
                  Icons.info_outline,
                  size: 25,
                  color: widget.habitColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: analyticsCards.map((card) {
                return AnalyticsCardWidget(
                  key: ValueKey(card.title),
                  analyticsCardInfo: card,
                  userLocale: userLocale,
                  color: widget.habitColor,
                );
              }).toList(),
            ),
          ),
        ],
      );
    } else {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(widget.habitColor),
        ),
      );
    }
  }
}
