import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';

class LastActivityWidget extends StatefulWidget {
  final List<HabitDailyTracking> habitDailyTrackings;
  final String userLocale;

  const LastActivityWidget({
    Key? key,
    required this.habitDailyTrackings,
    required this.userLocale,
  }) : super(key: key);

  @override
  State<LastActivityWidget> createState() => _LastActivityWidgetState();
}

class _LastActivityWidgetState extends State<LastActivityWidget> {
  late Timer _timer;
  DateTime? _lastActivityDateTime;

  @override
  void initState() {
    super.initState();

    widget.habitDailyTrackings.sort((a, b) => b.datetime.compareTo(a.datetime));
    _lastActivityDateTime = widget.habitDailyTrackings.isNotEmpty
        ? widget.habitDailyTrackings.first.datetime
        : null;

    // Only set up the timer if there's a valid last activity datetime
    if (_lastActivityDateTime != null) {
      // Calculate the time difference between the current time and the last activity
      final now = DateTime.now();
      final difference = now.difference(_lastActivityDateTime!);

      // Check the time difference and set the appropriate timer interval
      if (difference.inSeconds < 60) {
        // Less than 1 minute ago - refresh every second
        _timer = Timer.periodic(Duration(seconds: 1), (_) {
          setState(() {});
        });
      } else if (difference.inMinutes < 60) {
        // Less than 1 hour ago - refresh every minute
        _timer = Timer.periodic(Duration(minutes: 1), (_) {
          setState(() {});
        });
      } else {
        _timer = Timer.periodic(Duration(minutes: 5), (_) {
          setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  String formatTimeElapsed(BuildContext context, DateTime lastActivity) {
    final now = DateTime.now();
    final duration = now.difference(lastActivity);
    final localizations = AppLocalizations.of(context)!;

    if (duration.inSeconds < 60) {
      return localizations.lastActivitySeconds(duration.inSeconds);
    } else if (duration.inMinutes < 60) {
      return localizations.lastActivityMinutes(duration.inMinutes);
    } else if (duration.inHours < 24) {
      return localizations.lastActivityHours(duration.inHours);
    } else if (duration.inDays < 30) {
      return localizations.lastActivityDays(duration.inDays);
    } else if (duration.inDays < 365) {
      final months = (duration.inDays / 30).floor();
      return localizations.lastActivityMonths(months);
    } else {
      final years = (duration.inDays / 365).floor();
      return localizations.lastActivityYears(years);
    }
  }

  String getLastActivityText() {
    if (_lastActivityDateTime == null) {
      return AppLocalizations.of(context)!.noActivityRecordedYet;
    }
    return "${AppLocalizations.of(context)!.lastActivity} ${formatTimeElapsed(context, _lastActivityDateTime!)}";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      getLastActivityText(),
      style: const TextStyle(fontSize: 16),
    );
  }
}
