import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_message.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class PrivateMessageWidget extends StatelessWidget {
  final PrivateMessage message;
  final Color color;

  const PrivateMessageWidget({
    Key? key,
    required this.message,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserBloc>().state;
    final profileState = context.watch<ProfileBloc>().state;

    if (userState is UsersLoaded && profileState is ProfileAuthenticated) {
      final userLocale = profileState.profile.locale;
      final userIsCreator = message.creator == profileState.profile.id;

      return Align(
        alignment: userIsCreator ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color.withAlpha(100)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.content,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      message.updateAt == null
                          ? DateFormat.Hm().format(message.createdAt)
                          : AppLocalizations.of(context)!.editedAt(
                              DateFormat.yMEd(userLocale)
                                  .add_Hm()
                                  .format(message.updateAt!)),
                      style: TextStyle(
                        color: context.colors.hint,
                        fontSize: 12,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
