import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:reallystick/features/habits/domain/entities/habit_daily_tracking.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class LastActivityWidget extends StatefulWidget {
  final List<HabitDailyTracking> habitDailyTrackings;
  final String userLocale;

  const LastActivityWidget({
    super.key,
    required this.habitDailyTrackings,
    required this.userLocale,
  });

  @override
  State<LastActivityWidget> createState() => _LastActivityWidgetState();
}

class _LastActivityWidgetState extends State<LastActivityWidget> {
  Timer? _timer;
  DateTime? _lastActivityDateTime;

  @override
  void initState() {
    super.initState();

    _sortHabitDailyTrackings();
    _setupTimer();
  }

  @override
  void didUpdateWidget(covariant LastActivityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the new habitDailyTrackings is different from the old one
    if (!listEquals(
        oldWidget.habitDailyTrackings, widget.habitDailyTrackings)) {
      _sortHabitDailyTrackings();
      _setupTimer();
      setState(() {});
    }
  }

  void _sortHabitDailyTrackings() {
    widget.habitDailyTrackings.sort((a, b) => b.datetime.compareTo(a.datetime));
    _lastActivityDateTime = widget.habitDailyTrackings.isNotEmpty
        ? widget.habitDailyTrackings.first.datetime
        : null;
  }

  void _setupTimer() {
    _timer?.cancel(); // Cancel any existing timer

    if (_lastActivityDateTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_lastActivityDateTime!);

      if (difference.inSeconds < 60) {
        _timer = Timer.periodic(
          Duration(seconds: 1),
          (_) {
            setState(() {});
            _setupTimer();
          },
        );
      } else if (difference.inMinutes < 60) {
        _timer = Timer.periodic(
          Duration(minutes: 1),
          (_) {
            setState(() {});
            _setupTimer();
          },
        );
      } else {
        _timer = Timer.periodic(
          Duration(minutes: 5),
          (_) {
            setState(() {});
            _setupTimer();
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final localizations = AppLocalizations.of(context)!;
    if (_lastActivityDateTime == null) {
      return localizations.noActivityRecordedYet;
    }
    return "${localizations.lastActivity} ${formatTimeElapsed(context, _lastActivityDateTime!)}";
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      getLastActivityText(),
    );
  }
}
