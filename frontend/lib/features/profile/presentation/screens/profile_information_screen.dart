import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class ProfileInformationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profileInformation),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            return _buildProfileForm(context, state);
          } else if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(
              child: Text(AppLocalizations.of(context)!.failedToLoadProfile),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, ProfileAuthenticated state) {
    final profile = state.profile;

    // Function to generate age categories
    List<String> generateAgeCategories() {
      List<String> categories = [];
      for (int i = 15; i < 70; i += 5) {
        categories.add('$i - ${i + 5}');
      }
      categories.add('70+');
      return categories;
    }

    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        _buildDropdownField(
          context,
          label: AppLocalizations.of(context)!.ageCategory,
          value: profile.ageCategory,
          items: generateAgeCategories(),
          onChanged: (value) {
            final newProfile = state.profile;
            newProfile.ageCategory = value;
            _updateProfile(context, newProfile);
          },
        ),
        _buildDropdownField(
          context,
          label: AppLocalizations.of(context)!.gender,
          value: profile.gender,
          items: ['Male', 'Female', 'Non-binary'],
          onChanged: (value) {
            final newProfile = state.profile;
            newProfile.gender = value;
            _updateProfile(context, newProfile);
          },
        ),
        _buildDropdownField(
          context,
          label: AppLocalizations.of(context)!.continent,
          value: profile.continent,
          items: ['North America', 'Europe', 'Asia'], // TODO
          onChanged: (value) {
            final newProfile = state.profile;
            newProfile.continent = value;

            if (value == null) {
              newProfile.country = null;
              newProfile.region = null;
            }
            _updateProfile(context, newProfile);
          },
        ),

        // Show country field only if continent is set
        if (profile.continent != null)
          _buildTextField(
            context,
            label: AppLocalizations.of(context)!.country,
            value: profile.country, // TODO
            onChanged: (value) {
              final newProfile = state.profile;
              newProfile.country = value;

              if (value.isEmpty) {
                newProfile.region = null;
              }
              _updateProfile(context, newProfile);
            },
          ),

        // Show region field only if continent and country are set
        if (profile.continent != null &&
            profile.country != null &&
            profile.country!.isNotEmpty)
          _buildTextField(
            context,
            label: AppLocalizations.of(context)!.region,
            value: profile.region, // TODO
            onChanged: (value) {
              final newProfile = state.profile;
              newProfile.region = value;
              _updateProfile(context, newProfile);
            },
          ),

        _buildDropdownField(
          context,
          label: AppLocalizations.of(context)!.activity,
          value: profile.activity,
          items: ['Student', 'Unemployed', 'Worker'],
          onChanged: (value) {
            final newProfile = state.profile;
            newProfile.activity = value;
            _updateProfile(context, newProfile);
          },
        ),
        _buildDropdownField(
          context,
          label: AppLocalizations.of(context)!.financialSituation,
          value: profile.financialSituation,
          items: ['Low', 'Average', 'Good'],
          onChanged: (value) {
            final newProfile = state.profile;
            newProfile.financialSituation = value;
            _updateProfile(context, newProfile);
          },
        ),
        _buildDropdownField(context,
            label: AppLocalizations.of(context)!.livesInUrbanArea,
            value: profile.livesInUrbanArea == null
                ? null
                : profile.livesInUrbanArea!
                    ? 'Yes'
                    : 'No',
            items: ['No', 'Yes'], onChanged: (value) {
          final newProfile = state.profile;
          newProfile.livesInUrbanArea = value == null ? null : value == 'Yes';
          _updateProfile(context, newProfile);
        }),
        _buildDropdownField(context,
            label: AppLocalizations.of(context)!.relationshipStatus,
            value: profile.relationshipStatus,
            items: ['Single', 'In a relation', 'Married', 'Divorced'],
            onChanged: (value) {
          final newProfile = state.profile;
          newProfile.relationshipStatus = value;
          _updateProfile(context, newProfile);
        }),
        _buildDropdownField(
          context,
          label: AppLocalizations.of(context)!.levelOfEducation,
          value: profile.levelOfEducation,
          items: ['High School', 'College', 'Graduate'],
          onChanged: (value) {
            final newProfile = state.profile;
            newProfile.levelOfEducation = value;
            _updateProfile(context, newProfile);
          },
        ),
        _buildDropdownField(context,
            label: AppLocalizations.of(context)!.hasChildren,
            value: profile.hasChildren == null
                ? null
                : profile.hasChildren!
                    ? 'Yes'
                    : 'No',
            items: ['No', 'Yes'], onChanged: (value) {
          final newProfile = state.profile;
          newProfile.hasChildren = value == null ? null : value == 'Yes';
          _updateProfile(context, newProfile);
        }),
      ],
    );
  }

  void _updateProfile(BuildContext context, Profile profile) {
    BlocProvider.of<ProfileBloc>(context)
        .add(ProfileUpdateEvent(newProfile: profile));
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Create the list of dropdown items, adding a "None" option at the start.
    final dropdownItems = [
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          AppLocalizations.of(context)!.noAnswer,
          style: TextStyle(color: Colors.grey),
        ),
      ),
      ...items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        value: value,
        icon: Icon(Icons.arrow_drop_down),
        style: TextStyle(color: Colors.black, fontSize: 16),
        items: dropdownItems,
        hint: Text("Hint"),
        onChanged: onChanged,
        isExpanded: true,
        dropdownColor: Colors.white,
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
      ),
    );
  }
}
