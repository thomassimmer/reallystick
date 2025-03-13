import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({
    super.key,
  });

  @override
  StatisticsScreenState createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();

    // Schedule the event dispatch after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileAuthenticated) {
        BlocProvider.of<ProfileBloc>(context).add(GetStatisticsEvent());
      }
    });
  }

  Future<void> _pullRefresh() async {
    BlocProvider.of<ProfileBloc>(context).add(
      GetStatisticsEvent(),
    );
    await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileBloc>().state;

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.statistics,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _pullRefresh,
        child: FullWidthListView(
          children: [
            if (profileState is ProfileAuthenticated &&
                profileState.statistics != null) ...[
              SizedBox(height: 30),
              _buildStatisticRow(
                label: 'User Count: ',
                value: profileState.statistics!.userCount,
              ),
              _buildStatisticRow(
                label: 'User Token Count: ',
                value: profileState.statistics!.userTokenCount,
              ),
              _buildStatisticRow(
                label: 'Unit Count: ',
                value: profileState.statistics!.unitCount,
              ),
              _buildStatisticRow(
                label: 'Habit Category Count: ',
                value: profileState.statistics!.habitCategoryCount,
              ),
              _buildStatisticRow(
                label: 'Habit Count: ',
                value: profileState.statistics!.habitCount,
              ),
              _buildStatisticRow(
                label: 'Challenge Count: ',
                value: profileState.statistics!.challengeCount,
              ),
              _buildStatisticRow(
                label: 'Habit Participation Count: ',
                value: profileState.statistics!.habitParticipationCount,
              ),
              _buildStatisticRow(
                label: 'Challenge Participation Count: ',
                value: profileState.statistics!.challengeParticipationCount,
              ),
              _buildStatisticRow(
                label: 'Habit Daily Tracking Count: ',
                value: profileState.statistics!.habitDailyTrackingCount,
              ),
              _buildStatisticRow(
                label: 'Challenge Daily Tracking Count: ',
                value: profileState.statistics!.challengeDailyTrackingCount,
              ),
              _buildStatisticRow(
                label: 'Notification Count: ',
                value: profileState.statistics!.notificationCount,
              ),
              _buildStatisticRow(
                label: 'Private Discussion Count: ',
                value: profileState.statistics!.privateDiscussionCount,
              ),
              _buildStatisticRow(
                label: 'Private Message Count: ',
                value: profileState.statistics!.privateMessageCount,
              ),
              _buildStatisticRow(
                label: 'Public Message Count: ',
                value: profileState.statistics!.publicMessageCount,
              ),
              _buildStatisticRow(
                label: 'Public Message Like Count: ',
                value: profileState.statistics!.publicMessageLikeCount,
              ),
              _buildStatisticRow(
                label: 'Public Message Report Count: ',
                value: profileState.statistics!.publicMessageReportCount,
              ),
              _buildStatisticRow(
                label: 'Active Socket Count: ',
                value: profileState.statistics!.activeSocketCount,
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Reusable widget to build each statistic row
  Widget _buildStatisticRow({required String label, required int value}) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style:
                  context.typographies.bodySmall, // Small body font for label
            ),
            Text(
              value.toString(),
              style: context.typographies.bodySmall
                  .copyWith(fontWeight: FontWeight.bold), // Make value bold
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
