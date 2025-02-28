import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/private_message_content.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_update/private_message_update_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message_update/private_message_update_states.dart';

class PrivateMessageUpdateFormBloc
    extends Bloc<PrivateMessageUpdateFormEvent, PrivateMessageUpdateFormState> {
  PrivateMessageUpdateFormBloc()
      : super(const PrivateMessageUpdateFormState()) {
    on<PrivateMessageUpdateFormContentChangedEvent>(_contentChanged);
  }

  Future<void> _contentChanged(
      PrivateMessageUpdateFormContentChangedEvent event, Emitter emit) async {
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
