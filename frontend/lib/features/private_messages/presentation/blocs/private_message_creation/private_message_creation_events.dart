import 'package:equatable/equatable.dart';

sealed class PrivateMessageCreationFormEvent extends Equatable {
  const PrivateMessageCreationFormEvent();

  @override
  List<Object?> get props => [];
}

class PrivateMessageCreationFormContentChangedEvent
    extends PrivateMessageCreationFormEvent {
  final String? content;

  const PrivateMessageCreationFormContentChangedEvent(this.content);

  @override
  List<Object?> get props => [content];
}
