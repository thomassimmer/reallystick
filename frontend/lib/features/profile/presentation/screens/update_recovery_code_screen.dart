import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';

class UpdateRecoveryCodeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.changeRecoveryCode,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            return _buildRecoveryCodeView(context, state);
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

  Widget _buildRecoveryCodeView(
      BuildContext context, ProfileAuthenticated state) {
    void triggerGenerateNewRecoveryCode() {
      BlocProvider.of<ProfileBloc>(context).add(
        GenerateNewRecoveryCodeEvent(),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.recoveryCodeDescription,
                style: context.typographies.bodySmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              if (state.recoveryCode != null) ...[
                SelectableText(
                  state.recoveryCode!,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    size: 12,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: state.recoveryCode!));

                    final message = InfoMessage('recoveryCodeCopied');
                    GlobalSnackBar.show(context: context, message: message);
                  },
                ),
              ],
              ElevatedButton(
                onPressed: triggerGenerateNewRecoveryCode,
                style: context.styles.buttonSmall,
                child:
                    Text(AppLocalizations.of(context)!.generateNewRecoveryCode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
