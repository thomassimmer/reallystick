import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/app_logo.dart';
import 'package:reallystick/core/presentation/widgets/global_snack_bar.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/auth/presentation/widgets/background.dart';

class UnauthenticatedHomeScreen extends StatefulWidget {
  @override
  UnauthenticatedHomeScreenState createState() =>
      UnauthenticatedHomeScreenState();
}

class UnauthenticatedHomeScreenState extends State<UnauthenticatedHomeScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        GlobalSnackBar.show(context: context, message: state.message);
        if (state is AuthAuthenticatedState) {
          context.goNamed('home');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Background(),
            PageView(
              controller: _controller,
              scrollDirection: Axis.vertical,
              children: [
                _buildUnauthenticatedHomeScreen(context),
                _buildPresentationScreen(
                    "Become the best version of yourself."),
                _buildPresentationScreen("Try the beta version now."),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedHomeScreen(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
        AppLogo(size: 200),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Really',
              style: context.typographies.heading.copyWith(
                color: context.colors.background,
              ),
            ),
            Text(
              'Stick',
              style: context.typographies.heading.copyWith(
                color: context.colors.background,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.pleaseLoginOrSignUp,
          style: TextStyle(
            fontSize: 18,
            color: context.colors.background,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            context.goNamed('login');
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(context.colors.primary),
          ),
          child: Text(AppLocalizations.of(context)!.logIn),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            context.goNamed('signup');
          },
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(context.colors.secondary),
          ),
          child: Text(AppLocalizations.of(context)!.signUp),
        ),
        Spacer(),
        Text(
          AppLocalizations.of(context)!.whatIsThis,
          style: context.typographies.bodySmall.copyWith(
            color: context.colors.background,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_down,
              size: 40,
              color: context.colors.background,
            ),
            Transform.translate(
              offset: Offset(0, -30),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 35,
                color: context.colors.background,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresentationScreen(String title) {
    return Center(
      child: Text(
        title,
        style: context.typographies.heading.copyWith(
          color: context.colors.background,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
