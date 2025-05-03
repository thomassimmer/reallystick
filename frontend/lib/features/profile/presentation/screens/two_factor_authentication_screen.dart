import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/presentation/widgets/custom_app_bar.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class TwoFactorAuthenticationScreen extends StatelessWidget {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(
          AppLocalizations.of(context)!.twoFA,
          style: context.typographies.headingSmall,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileAuthenticated) {
            if (state.profile.otpVerified) {
              return _buildTwoFactorAuthenticationRegenerateConfigOrDisableView(
                  context, state);
            } else if (state.profile.otpAuthUrl != null) {
              return _buildOneTimePasswordVerificationView(context, state);
            } else {
              return _buildTwoFactorAuthenticationSetupView(context, state);
            }
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

  Widget _buildTwoFactorAuthenticationRegenerateConfigOrDisableView(
    BuildContext context,
    ProfileAuthenticated state,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.twoFAIsWellSetup,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<ProfileBloc>(context).add(
                        ProfileGenerateTwoFactorAuthenticationConfigEvent(),
                      );
                    },
                    style: context.styles.buttonMedium,
                    child:
                        Text(AppLocalizations.of(context)!.generateNewQrCode),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<ProfileBloc>(context).add(
                        ProfileDisableTwoFactorAuthenticationEvent(),
                      );
                    },
                    style: context.styles.buttonMedium,
                    child: Text(AppLocalizations.of(context)!.disableTwoFA),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOneTimePasswordVerificationView(
      BuildContext context, ProfileAuthenticated state) {
    void triggerOneTimePasswordVerification() {
      BlocProvider.of<ProfileBloc>(context).add(
        ProfileVerifyOneTimePasswordEvent(
          code: _otpController.text,
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context)!.twoFAScanQrCode,
                  ),
                  SizedBox(height: 16),
                  QrImageView(
                    data: state.profile.otpAuthUrl!,
                    version: QrVersions.auto,
                    size: screenWidth * 0.4,
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<ProfileBloc>(context).add(
                        ProfileGenerateTwoFactorAuthenticationConfigEvent(),
                      );
                    },
                    style: context.styles.buttonMedium,
                    child: Text(AppLocalizations.of(context)!.regenerateQrCode),
                  ),
                  SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.twoFASecretKey),
                  SizedBox(height: 16),
                  SelectableText(
                    state.profile.otpBase32!,
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: 15,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: state.profile.otpBase32!));

                      final message = InfoMessage('qrCodeSecretKeyCopied');
                      GlobalSnackBar.show(context: context, message: message);
                    },
                  ),
                  SizedBox(height: 16),
                  IntrinsicWidth(
                    child: Column(
                      children: [
                        AutofillGroup(
                          child: CustomTextField(
                            controller: _otpController,
                            label: AppLocalizations.of(context)!.validationCode,
                            obscureText: true,
                            onFieldSubmitted: (_) =>
                                triggerOneTimePasswordVerification(),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            keyboardType: TextInputType.number,
                            autofillHints: [AutofillHints.oneTimeCode],
                          ),
                        ),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                BlocProvider.of<ProfileBloc>(context).add(
                                  ProfileDisableTwoFactorAuthenticationEvent(),
                                );
                              },
                              style: context.styles.buttonMedium,
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: triggerOneTimePasswordVerification,
                              style: context.styles.buttonMedium,
                              child: Text(AppLocalizations.of(context)!.verify),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTwoFactorAuthenticationSetupView(
      BuildContext context, ProfileAuthenticated state) {
    return SingleChildScrollView(
        child: Column(
      children: [
        Center(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Text(
                    AppLocalizations.of(context)!.twoFASetup,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<ProfileBloc>(context).add(
                        ProfileGenerateTwoFactorAuthenticationConfigEvent(),
                      );
                    },
                    style: context.styles.buttonMedium,
                    child: Text(AppLocalizations.of(context)!.enable),
                  ),
                ])))
      ],
    ));
  }
}
