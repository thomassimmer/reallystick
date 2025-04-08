import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/messages/errors/domain_error.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/app_logo.dart';
import 'package:reallystick/core/presentation/widgets/custom_container.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth_login/auth_login_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth_login/auth_login_events.dart';
import 'package:reallystick/features/auth/presentation/widgets/background.dart';
import 'package:reallystick/features/auth/presentation/widgets/successful_login_animation.dart';

class SignupScreen extends StatefulWidget {
  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    final authMessage = context.select((AuthBloc bloc) => bloc.state.message);

    return Scaffold(
        body: Stack(children: [
      Background(),
      if (!_isAuthenticated)
        SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppLogo(),
                          SizedBox(height: 40),
                          CustomContainer(
                            child: BlocConsumer<AuthBloc, AuthState>(
                              listener: (context, state) {
                                if (state
                                    is AuthAuthenticatedAfterRegistrationState) {
                                  setState(() {
                                    _isAuthenticated = true;
                                  });
                                } else {
                                  GlobalSnackBar.show(
                                    context: context,
                                    message: state.message,
                                  );
                                }
                              },
                              builder: (context, state) {
                                if (state is AuthLoadingState) {
                                  return _buildLoadingScreen(context, state);
                                } else {
                                  return _buildSignUpScreen(context, state);
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.goNamed('home');
                            },
                            child: Text(
                              AppLocalizations.of(context)!.comeBack,
                            ),
                          ),
                        ])))),
      SuccessfulLoginAnimation(
        isVisible: _isAuthenticated,
        onAnimationComplete: () {
          GlobalSnackBar.show(context: context, message: authMessage);
          context.goNamed('recovery-code');
        },
      ),
    ]));
  }

  Widget _buildLoadingScreen(BuildContext context, AuthState state) {
    return Column(children: [CircularProgressIndicator()]);
  }

  Widget _buildSignUpScreen(BuildContext context, AuthState state) {
    final Brightness brightness = MediaQuery.of(context).platformBrightness;
    final String themeData = brightness == Brightness.dark ? "dark" : "light";

    final displayUsernameError = context.select(
      (AuthSignupFormBloc authSignupFormBloc) =>
          authSignupFormBloc.state.username.displayError,
    );
    final displayUsernameErrorMessage = displayUsernameError is DomainError
        ? getTranslatedMessage(
            context, ErrorMessage(displayUsernameError.messageKey))
        : null;

    final displayPasswordError = context.select(
      (AuthSignupFormBloc authSignupFormBloc) =>
          authSignupFormBloc.state.password.displayError,
    );
    final displayPasswordErrorMessage = displayPasswordError is DomainError
        ? getTranslatedMessage(
            context, ErrorMessage(displayPasswordError.messageKey))
        : null;

    void triggerSignUp() {
      BlocProvider.of<AuthBloc>(context).add(
        AuthSignupEvent(
            username: _usernameController.text,
            password: _passwordController.text,
            theme: themeData),
      );
    }

    return Builder(
      builder: (context) => Column(
        children: [
          Text(
            AppLocalizations.of(context)!.signUp,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _usernameController,
            onChanged: (username) =>
                BlocProvider.of<AuthSignupFormBloc>(context)
                    .add(SignupFormUsernameChangedEvent(username)),
            label: AppLocalizations.of(context)!.username,
            obscureText: false,
            errorText: displayUsernameErrorMessage,
          ),
          SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            onChanged: (password) =>
                BlocProvider.of<AuthSignupFormBloc>(context)
                    .add(SignupFormPasswordChangedEvent(password)),
            obscureText: true,
            label: AppLocalizations.of(context)!.password,
            errorText: displayPasswordErrorMessage,
            onFieldSubmitted: (_) => triggerSignUp(),
          ),
          SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
              children: [
                TextSpan(
                    text: AppLocalizations.of(context)!.bySigningUpYouAgree),
                TextSpan(text: '\n'),
                TextSpan(
                  text: AppLocalizations.of(context)!.termsOfUse,
                  style: TextStyle(
                      color: context.colors.primary,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.pushNamed('terms-of-use'),
                ),
                TextSpan(text: ' ${AppLocalizations.of(context)!.and} '),
                TextSpan(
                  text: AppLocalizations.of(context)!.privacyPolicy,
                  style: TextStyle(
                      color: context.colors.primary,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.pushNamed('privacy-policy'),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: triggerSignUp,
            child: Text(
              AppLocalizations.of(context)!.signUp,
            ),
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () {
              context.goNamed('login');
            },
            child: Text(AppLocalizations.of(context)!.alreadyAnAccountLogin),
          ),
        ],
      ),
    );
  }
}
