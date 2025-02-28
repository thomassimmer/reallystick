import 'package:equatable/equatable.dart';

sealed class PrivateMessageUpdateFormEvent extends Equatable {
  const PrivateMessageUpdateFormEvent();

  @override
  List<Object?> get props => [];
}

class PrivateMessageUpdateFormContentChangedEvent
    extends PrivateMessageUpdateFormEvent {
  final String? content;

  const PrivateMessageUpdateFormContentChangedEvent(this.content);

  @override
  List<Object?> get props => [content];
}
