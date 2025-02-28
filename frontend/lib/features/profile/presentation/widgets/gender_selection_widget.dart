import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/profile/domain/entities/gender_status.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';

class GenderSelectionWidget extends StatelessWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const GenderSelectionWidget(
      {Key? key, required this.profile, required this.updateProfile})
      : super(key: key);

  String _getLocalizedStatus(BuildContext context, GenderStatus status) {
    switch (status) {
      case GenderStatus.male:
        return AppLocalizations.of(context)!.male;
      case GenderStatus.female:
        return AppLocalizations.of(context)!.female;
      case GenderStatus.other:
        return AppLocalizations.of(context)!.other;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownWidget.show(
      context,
      label: AppLocalizations.of(context)!.gender,
      value: profile.gender,
      items: GenderStatus.values.map((status) {
        return DropdownMenuItem(
          value: status.toShortString(),
          child: Text(_getLocalizedStatus(context, status)),
        );
      }).toList(),
      onChanged: (value) {
        final newProfile = profile;
        newProfile.gender = value;
        updateProfile(context, newProfile);
      },
    );
  }
}
