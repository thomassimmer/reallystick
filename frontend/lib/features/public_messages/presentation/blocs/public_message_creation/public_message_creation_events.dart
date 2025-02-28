import 'package:equatable/equatable.dart';

sealed class PublicMessageCreationFormEvent extends Equatable {
  const PublicMessageCreationFormEvent();

  @override
  List<Object?> get props => [];
}

class PublicMessageCreationFormContentChangedEvent
    extends PublicMessageCreationFormEvent {
  final String? content;

  const PublicMessageCreationFormContentChangedEvent(this.content);

  @override
  List<Object?> get props => [content];
}
