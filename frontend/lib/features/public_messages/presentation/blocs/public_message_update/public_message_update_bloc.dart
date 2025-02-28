import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/public_message_content.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_update/public_message_update_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message_update/public_message_update_states.dart';

class PublicMessageUpdateFormBloc
    extends Bloc<PublicMessageUpdateFormEvent, PublicMessageUpdateFormState> {
  PublicMessageUpdateFormBloc() : super(const PublicMessageUpdateFormState()) {
    on<PublicMessageUpdateFormContentChangedEvent>(_contentChanged);
  }

  Future<void> _contentChanged(
      PublicMessageUpdateFormContentChangedEvent event, Emitter emit) async {
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
