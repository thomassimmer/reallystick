import 'package:flutter/material.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/domain/entities/relationship_status.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class RelationStatusSelectionWidget extends StatelessWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const RelationStatusSelectionWidget(
      {super.key, required this.profile, required this.updateProfile});

  @override
  Widget build(BuildContext context) {
    return DropdownWidget.show(
      context,
      label: AppLocalizations.of(context)!.relationshipStatus,
      value: profile.relationshipStatus,
      items: RelationshipStatus.values.map((status) {
        return DropdownMenuItem(
          value: status.toShortString(),
          child: Text(status.getLocalizedStatus(context)),
        );
      }).toList(),
      onChanged: (value) {
        final newProfile = profile;
        newProfile.relationshipStatus = value;
        updateProfile(context, newProfile);
      },
    );
  }
}
