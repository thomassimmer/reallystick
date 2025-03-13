import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/ui/extensions.dart';

class DateWidget extends StatefulWidget {
  final DateTime datetime;
  final String userLocale;

  const DateWidget({
    super.key,
    required this.datetime,
    required this.userLocale,
  });

  @override
  State<DateWidget> createState() => _DateWidgetState();
}

class _DateWidgetState extends State<DateWidget> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Only set up the timer if there's a valid last activity datetime
    // Calculate the time difference between the current time and the last activity
    final now = DateTime.now();
    final difference = now.difference(widget.datetime);

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

  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel(); // Cancel the timer when the widget is disposed
    }
    super.dispose();
  }

  String formatTimeElapsed(BuildContext context, DateTime datetime) {
    final now = DateTime.now();
    final duration = now.difference(datetime);
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

  @override
  Widget build(BuildContext context) {
    return Text(
      formatTimeElapsed(context, widget.datetime),
      style: TextStyle(
        color: context.colors.hint,
        fontSize: 12,
      ),
    );
  }
}
