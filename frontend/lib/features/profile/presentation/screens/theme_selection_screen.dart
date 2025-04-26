import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/full_width_list_view.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class ThemeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.selectTheme,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            return _buildThemeSelectionView(context, state);
          } else if (state is ProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(
                child: Text(AppLocalizations.of(context)!.failedToLoadProfile));
          }
        },
      ),
    );
  }

  Widget _buildThemeSelectionView(
      BuildContext context, ProfileAuthenticated state) {
    final List<Map<String, String>> themes = [
      {'code': 'light', 'name': AppLocalizations.of(context)!.light},
      {'code': 'dark', 'name': AppLocalizations.of(context)!.dark},
    ];

    return FullWidthListView(
        children: themes.map((theme) {
      return ListTile(
        title: Text(theme['name']!),
        leading: Radio<String>(
          value: theme['code']!,
          groupValue: state.profile.theme,
          onChanged: (String? value) {
            final newProfile = state.profile;
            newProfile.theme = value!;
            BlocProvider.of<ProfileBloc>(context)
                .add(ProfileUpdateEvent(newProfile: newProfile));
          },
        ),
      );
    }).toList());
  }
}
