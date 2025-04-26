import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class ConfirmMessageDeletionModal extends StatefulWidget {
  final PublicMessage message;
  final bool deletedByAdmin;

  const ConfirmMessageDeletionModal({
    required this.message,
    required this.deletedByAdmin,
  });

  @override
  ConfirmMessageDeletionModalState createState() =>
      ConfirmMessageDeletionModalState();
}

class ConfirmMessageDeletionModalState
    extends State<ConfirmMessageDeletionModal> {
  void _deleteMessage() {
    final newMessageEvent = DeletePublicMessageEvent(
      message: widget.message,
      deletedByAdmin: widget.deletedByAdmin,
    );

    if (mounted) {
      context.read<PublicMessageBloc>().add(newMessageEvent);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.deleteMessage,
          textAlign: TextAlign.center,
          style: context.typographies.headingSmall,
        ),
        const SizedBox(height: 16),
        Text(AppLocalizations.of(context)!.confirmMessageDeletion),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _deleteMessage,
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
