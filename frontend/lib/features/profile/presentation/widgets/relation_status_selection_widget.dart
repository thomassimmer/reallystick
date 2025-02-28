import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/domain/entities/relationship_status.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';

class RelationStatusSelectionWidget extends StatelessWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const RelationStatusSelectionWidget(
      {Key? key, required this.profile, required this.updateProfile})
      : super(key: key);

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
