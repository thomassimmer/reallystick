import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/messages/message_mapper.dart';
import 'package:reallystick/core/presentation/widgets/custom_text_field.dart';
import 'package:reallystick/core/ui/extensions.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_report_creation/public_message_report_creation_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_report_creation/public_message_report_creation_events.dart';
import 'package:reallystick/i18n/app_localizations.dart';

class CreateMessageReportModal extends StatefulWidget {
  final PublicMessage message;

  const CreateMessageReportModal({
    required this.message,
  });

  @override
  CreateMessageReportModalState createState() =>
      CreateMessageReportModalState();
}

class CreateMessageReportModalState extends State<CreateMessageReportModal> {
  String? _reason;

  void _reportMessage() {
    final publicMessageReportCreationFormBloc =
        context.read<PublicMessageReportCreationFormBloc>();

    publicMessageReportCreationFormBloc.add(
      PublicMessageReportCreationFormReasonChangedEvent(_reason),
    );

    Future.delayed(const Duration(milliseconds: 50), () {
      if (publicMessageReportCreationFormBloc.state.isValid) {
        final newMessageReportEvent = CreatePublicMessageReportEvent(
          message: widget.message,
          reason: _reason!,
        );

        if (mounted) {
          context.read<PublicMessageBloc>().add(newMessageReportEvent);
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayReasonErrorMessage = context.select(
      (PublicMessageReportCreationFormBloc bloc) {
        final error = bloc.state.reason.displayError;
        return error != null
            ? getTranslatedMessage(context, ErrorMessage(error.messageKey))
            : null;
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.reportMessage,
          textAlign: TextAlign.center,
          style: context.typographies.headingSmall,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          initialValue: _reason,
          maxLines: null,
          minLines: 3,
          keyboardType: TextInputType.multiline,
          label: AppLocalizations.of(context)!.reason,
          onChanged: (value) {
            setState(() {
              _reason = value;
            });
            BlocProvider.of<PublicMessageReportCreationFormBloc>(context).add(
              PublicMessageReportCreationFormReasonChangedEvent(_reason),
            );
          },
          errorText: displayReasonErrorMessage,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _reportMessage,
          child: Text(AppLocalizations.of(context)!.create),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
