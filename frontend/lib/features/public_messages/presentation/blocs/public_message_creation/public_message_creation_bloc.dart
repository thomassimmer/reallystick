import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/public_message_content.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_creation/public_message_creation_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_creation/public_message_creation_states.dart';

class PublicMessageCreationFormBloc extends Bloc<PublicMessageCreationFormEvent,
    PublicMessageCreationFormState> {
  PublicMessageCreationFormBloc()
      : super(const PublicMessageCreationFormState()) {
    on<PublicMessageCreationFormContentChangedEvent>(_contentChanged);
  }

  Future<void> _contentChanged(
      PublicMessageCreationFormContentChangedEvent event, Emitter emit) async {
    final content = PublicMessageContentValidator.dirty(event.content);

    emit(
      state.copyWith(
        content: content,
        isValid: Formz.validate([
          content,
        ]),
      ),
    );
  }
}
