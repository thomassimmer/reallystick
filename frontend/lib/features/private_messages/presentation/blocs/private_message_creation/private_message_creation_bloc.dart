import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/private_message_content.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_creation/private_message_creation_states.dart';

class PrivateMessageCreationFormBloc extends Bloc<
    PrivateMessageCreationFormEvent, PrivateMessageCreationFormState> {
  PrivateMessageCreationFormBloc()
      : super(const PrivateMessageCreationFormState()) {
    on<PrivateMessageCreationFormContentChangedEvent>(_contentChanged);
  }

  Future<void> _contentChanged(
      PrivateMessageCreationFormContentChangedEvent event, Emitter emit) async {
    final content = PrivateMessageContentValidator.dirty(event.content);

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
