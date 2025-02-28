import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/profile/domain/entities/level_of_education_status.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';

class LevelOfEducationSelectionWidget extends StatelessWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const LevelOfEducationSelectionWidget(
      {Key? key, required this.profile, required this.updateProfile})
      : super(key: key);

  String _getLocalizedStatus(
      BuildContext context, LevelOfEducationStatus status) {
    switch (status) {
      case LevelOfEducationStatus.highSchoolOrLess:
        return AppLocalizations.of(context)!.highSchoolOrLess;
      case LevelOfEducationStatus.highSchoolPlusOneOrTwoYears:
        return AppLocalizations.of(context)!.highSchoolPlusOneOrTwoYears;
      case LevelOfEducationStatus.highSchoolPlusThreeOrFourYears:
        return AppLocalizations.of(context)!.highSchoolPlusThreeOrFourYears;
      case LevelOfEducationStatus.highSchoolPlusFiveOrMoreYears:
        return AppLocalizations.of(context)!.highSchoolPlusFiveOrMoreYears;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownWidget.show(
      context,
      label: AppLocalizations.of(context)!.levelOfEducation,
      value: profile.levelOfEducation,
      items: LevelOfEducationStatus.values.map((status) {
        return DropdownMenuItem(
          value: status.toShortString(),
          child: Text(_getLocalizedStatus(context, status)),
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
