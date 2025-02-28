import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HabitDiscussionListWidget extends StatelessWidget {
  final Color habitColor;

  const HabitDiscussionListWidget({required this.habitColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.forum,
              size: 30,
              color: habitColor,
            ),
            SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.discussions,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: habitColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Container(
          height: 100,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                habitColor.withAlpha(100),
                habitColor.withBlue(100).withAlpha(100)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.discussionsComingSoon,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
