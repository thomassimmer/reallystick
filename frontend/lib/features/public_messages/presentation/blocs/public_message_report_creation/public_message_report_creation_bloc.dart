import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/public_message_content.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_report_creation/public_message_report_creation_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_report_creation/public_message_report_creation_states.dart';

class PublicMessageReportCreationFormBloc extends Bloc<
    PublicMessageReportCreationFormEvent,
    PublicMessageReportCreationFormState> {
  PublicMessageReportCreationFormBloc()
      : super(const PublicMessageReportCreationFormState()) {
    on<PublicMessageReportCreationFormReasonChangedEvent>(_contentChanged);
  }

  Future<void> _contentChanged(
      PublicMessageReportCreationFormReasonChangedEvent event,
      Emitter emit) async {
    final reason = PublicMessageContentValidator.dirty(event.reason);

    emit(
      state.copyWith(
        reason: reason,
        isValid: Formz.validate([
          reason,
        ]),
      ),
    );
  }
}
