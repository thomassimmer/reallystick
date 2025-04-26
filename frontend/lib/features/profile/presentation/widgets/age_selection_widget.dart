import 'package:flutter/material.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class AgeSelectionWidget extends StatelessWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const AgeSelectionWidget(
      {super.key, required this.profile, required this.updateProfile});

  List<String> generateAgeCategories() {
    List<String> categories = [];
    for (int i = 15; i < 70; i += 5) {
      categories.add('$i - ${i + 5}');
    }
    categories.add('70+');
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownWidget.show(
      context,
      label: AppLocalizations.of(context)!.ageCategory,
      value: profile.ageCategory,
      items: generateAgeCategories().map((category) {
        return DropdownMenuItem(
          value: category.toString(),
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        final newProfile = profile;
        newProfile.ageCategory = value;
        updateProfile(context, newProfile);
      },
    );
  }
}
