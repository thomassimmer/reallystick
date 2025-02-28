import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';

class HasChildrenSelectionWidget extends StatelessWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const HasChildrenSelectionWidget(
      {Key? key, required this.profile, required this.updateProfile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownWidget.show(context,
        label: AppLocalizations.of(context)!.hasChildren,
        value: profile.hasChildren?.toString(),
        items: [
          DropdownMenuItem(
            value: true.toString(),
            child: Text(AppLocalizations.of(context)!.yes),
          ),
          DropdownMenuItem(
            value: false.toString(),
            child: Text(AppLocalizations.of(context)!.no),
          )
        ], onChanged: (value) {
      final newProfile = profile;
      newProfile.hasChildren =
          value == null ? null : value == AppLocalizations.of(context)!.yes;
      updateProfile(context, newProfile);
    });
  }
}
