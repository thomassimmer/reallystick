import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/features/profile/data/models/country.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/widgets/dropdown_widget.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class LocationSelectionWidget extends StatefulWidget {
  final Profile profile;
  final void Function(BuildContext context, Profile profile) updateProfile;

  const LocationSelectionWidget({
    super.key,
    required this.profile,
    required this.updateProfile,
  });

  @override
  LocationSelectionState createState() => LocationSelectionState();
}

class LocationSelectionState extends State<LocationSelectionWidget> {
  List<Country> countries = [];
  List<String> regions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeRegions();
    });
  }

  Future<void> initializeRegions() async {
    final result =
        await BlocProvider.of<ProfileBloc>(context).loadCountriesUseCase.call();

    result.fold(
      (error) {
        GlobalSnackBar.show(
            context: context, message: ErrorMessage(error.messageKey));
      },
      (newCountries) {
        List<String> newRegions =
            newCountries.map((country) => country.region).toSet().toList();

        setState(() {
          countries = newCountries;
          regions = newRegions;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Country> countriesInRegion = countries
        .where((country) => country.region == widget.profile.region)
        .toList();

    return Column(
      children: [
        DropdownWidget.show(
          context,
          label: AppLocalizations.of(context)!.region,
          value: regions.contains(widget.profile.region)
              ? widget.profile.region
              : null,
          items: [
            ...regions.map((region) {
              return DropdownMenuItem<String>(
                value: region,
                child: Text(region),
              );
            })
          ],
          onChanged: (value) {
            final newProfile = widget.profile;
            newProfile.region = value;

            if (value == null) {
              newProfile.country = null;
            }

            widget.updateProfile(context, newProfile);
          },
        ),

        // Country Dropdown (only show if a region is selected)
        if (widget.profile.region != null)
          _buildCountryDropdownField(
            label: AppLocalizations.of(context)!.country,
            value: countriesInRegion
                    .where((country) =>
                        country.name.common == widget.profile.country)
                    .isNotEmpty
                ? widget.profile.country
                : null,
            countries: countriesInRegion,
            onChanged: (value) {
              final newProfile = widget.profile;
              newProfile.country = value;
              widget.updateProfile(context, newProfile);
            },
          )
      ],
    );
  }

  Widget _buildCountryDropdownField({
    required String label,
    required String? value,
    required List<Country> countries,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text(
            AppLocalizations.of(context)!.noAnswer,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ...countries.map((country) {
          return DropdownMenuItem(
            value: country.name.common,
            child: Row(
              children: [
                Image.network(country.flags.png, width: 24, height: 16),
                SizedBox(width: 8),
                Text(country.name.nativeName.entries.first.value.common),
              ],
            ),
          );
        })
      ],
      onChanged: onChanged,
    );
  }
}
