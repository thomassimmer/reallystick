import 'package:flutter/material.dart';
import 'package:reallystick/features/profile/domain/entities/level_of_education_status.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class LevelOfEducationSelectionWidget extends StatelessWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const LevelOfEducationSelectionWidget(
      {super.key, required this.profile, required this.updateProfile});

  @override
  Widget build(BuildContext context) {
    return DropdownWidget.show(
      context,
      label: AppLocalizations.of(context)!.levelOfEducation,
      value: profile.levelOfEducation,
      items: LevelOfEducationStatus.values.map((status) {
        return DropdownMenuItem(
          value: status.toShortString(),
          child: Text(status.getLocalizedStatus(context)),
        );
      }).toList(),
      onChanged: (value) {
        final newProfile = profile;
        newProfile.levelOfEducation = value;
        updateProfile(context, newProfile);
      },
    );
  }
}
