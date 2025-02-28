import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/profile/domain/entities/activity_status.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';

class ActivitySelectionWidget extends StatelessWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const ActivitySelectionWidget(
      {Key? key, required this.profile, required this.updateProfile})
      : super(key: key);

  String _getLocalizedStatus(BuildContext context, ActivityStatus status) {
    switch (status) {
      case ActivityStatus.student:
        return AppLocalizations.of(context)!.student;
      case ActivityStatus.unemployed:
        return AppLocalizations.of(context)!.unemployed;
      case ActivityStatus.worker:
        return AppLocalizations.of(context)!.worker;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownWidget.show(
      context,
      label: AppLocalizations.of(context)!.activity,
      value: profile.activity,
      items: ActivityStatus.values.map((status) {
        return DropdownMenuItem(
          value: status.toShortString(),
          child: Text(_getLocalizedStatus(context, status)),
        );
      }).toList(),
      onChanged: (value) {
        final newProfile = profile;
        newProfile.activity = value;
        updateProfile(context, newProfile);
      },
    );
  }
}
