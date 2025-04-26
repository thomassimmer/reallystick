import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_creation/public_message_creation_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_creation/public_message_creation_events.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class AddThreadModal extends StatefulWidget {
  final String? habitId;
  final String? challengeId;

  const AddThreadModal({
    required this.habitId,
    required this.challengeId,
  });

  @override
  AddThreadModalState createState() => AddThreadModalState();
}

class AddThreadModalState extends State<AddThreadModal> {
  String? _content;

  void addThread() {
    final publicMessageCreationFormBloc =
        context.read<PublicMessageCreationFormBloc>();

    // Dispatch validation events for all fields
    publicMessageCreationFormBloc.add(
      PublicMessageCreationFormContentChangedEvent(_content),
    );

    // Allow time for the validation states to update
    Future.delayed(
      const Duration(milliseconds: 50),
      () {
        if (publicMessageCreationFormBloc.state.isValid) {
          final newPublicMessageEvent = CreatePublicMessageEvent(
            content: _content!,
            habitId: widget.habitId,
            challengeId: widget.challengeId,
            repliesTo: null,
            threadId: null,
          );
          if (mounted) {
            context.read<PublicMessageBloc>().add(newPublicMessageEvent);
            Navigator.of(context).pop();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayContentErrorMessage = context.select(
      (PublicMessageCreationFormBloc bloc) {
        final error = bloc.state.content.displayError;
        return error != null
            ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
            : null;
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.addNewDiscussion,
          textAlign: TextAlign.center,
          style: context.typographies.headingSmall,
        ),

        const SizedBox(height: 16),

        CustomTextField(
          initialValue: _content,
          maxLines: null,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          label: AppLocalizations.of(context)!.message,
          onChanged: (value) {
            setState(() {
              _content = value;
            });
            BlocProvider.of<PublicMessageCreationFormBloc>(context).add(
              PublicMessageCreationFormContentChangedEvent(_content),
            );
          },
          errorText: displayContentErrorMessage,
        ),

        const SizedBox(height: 16),

        // Save Button
        ElevatedButton(
          onPressed: addThread,
          child: Text(AppLocalizations.of(context)!.create),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}
