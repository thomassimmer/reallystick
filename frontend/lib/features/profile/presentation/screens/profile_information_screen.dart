import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/profile/domain/entities/profile.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/profile/presentation/widgets/activity_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/age_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/financial_situation_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/gender_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/has_children_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/level_of_education_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/living_in_urban_area_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/location_selection_widget.dart';
import 'package:reallystick/features/profile/presentation/widgets/relation_status_selection_widget.dart';

class ProfileInformationScreen extends StatefulWidget {
  @override
  ProfileInformationState createState() => ProfileInformationState();
}

class ProfileInformationState extends State<ProfileInformationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profileInformation,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
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

    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        AgeSelectionWidget(profile: profile, updateProfile: updateProfile),
        GenderSelectionWidget(
          profile: profile,
          updateProfile: updateProfile,
        ),
        LocationSelectionWidget(profile: profile, updateProfile: updateProfile),
        LivingInUrbanAreaSelectionWidget(
            profile: profile, updateProfile: updateProfile),
        ActivitySelectionWidget(profile: profile, updateProfile: updateProfile),
        LevelOfEducationSelectionWidget(
            profile: profile, updateProfile: updateProfile),
        FinancialSituationSelectionWidget(
            profile: profile, updateProfile: updateProfile),
        RelationStatusSelectionWidget(
            profile: profile, updateProfile: updateProfile),
        HasChildrenSelectionWidget(
            profile: profile, updateProfile: updateProfile),
      ],
    );
  }

  void updateProfile(BuildContext context, Profile profile) {
    BlocProvider.of<ProfileBloc>(context)
        .add(ProfileUpdateEvent(newProfile: profile));
  }
}
