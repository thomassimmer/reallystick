import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:reallystick/core/presentation/widgets/app_logo.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class ErrorScreen extends StatelessWidget {
  final GoException? error;

  const ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      return Scaffold(
        backgroundColor: context.colors.primary,
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              TextButton(
                onPressed: () {
                  context.goNamed('home');
                },
                child: Row(
                  children: [
                    AppLogo(size: 50),
                    SizedBox(width: 10),
                    Text('Really', style: context.typographies.headingSmall),
                    Text('Stick', style: context.typographies.headingSmall),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: context.colors.primary,
        ),
        body: Center(
          child: Text(error != null
              ? error.toString()
              : AppLocalizations.of(context)!.defaultError),
        ),
      );
    });
  }
}
