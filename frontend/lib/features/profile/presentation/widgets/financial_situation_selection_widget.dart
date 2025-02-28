import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/profile/domain/entities/financial_situation_status.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';

class FinancialSituationSelectionWidget extends StatelessWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const FinancialSituationSelectionWidget(
      {Key? key, required this.profile, required this.updateProfile})
      : super(key: key);

  String _getLocalizedStatus(
      BuildContext context, FinancialSituationStatus status) {
    switch (status) {
      case FinancialSituationStatus.poor:
        return AppLocalizations.of(context)!.poor;
      case FinancialSituationStatus.average:
        return AppLocalizations.of(context)!.average;
      case FinancialSituationStatus.wealthy:
        return AppLocalizations.of(context)!.wealthy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownWidget.show(
      context,
      label: AppLocalizations.of(context)!.financialSituation,
      value: profile.financialSituation,
      items: FinancialSituationStatus.values.map((status) {
        return DropdownMenuItem(
          value: status.toShortString(),
          child: Text(_getLocalizedStatus(context, status)),
        );
      }).toList(),
      onChanged: (value) {
        final newProfile = profile;
        newProfile.financialSituation = value;
        updateProfile(context, newProfile);
      },
    );
  }
}
