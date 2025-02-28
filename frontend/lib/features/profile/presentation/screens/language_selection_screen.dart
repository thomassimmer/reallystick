import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/constants/locales.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class LocaleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.selectLanguage,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            return _buildLocaleSelectionView(context, state);
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

  Widget _buildLocaleSelectionView(
      BuildContext context, ProfileAuthenticated state) {
    return Column(
      children: locales.map(
        (locale) {
          return ListTile(
            title: Text(locale['name']!),
            leading: Radio<String>(
              value: locale['code']!,
              groupValue: state.profile.locale,
              onChanged: (String? value) {
                final newProfile = state.profile;
                newProfile.locale = value!;
                BlocProvider.of<ProfileBloc>(context)
                    .add(ProfileUpdateEvent(newProfile: newProfile));
              },
            ),
          );
        },
      ).toList(),
    );
  }
}
