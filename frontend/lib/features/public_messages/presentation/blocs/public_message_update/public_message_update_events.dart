import 'package:equatable/equatable.dart';

sealed class PublicMessageUpdateFormEvent extends Equatable {
  const PublicMessageUpdateFormEvent();

  @override
  List<Object?> get props => [];
}

class PublicMessageUpdateFormContentChangedEvent
    extends PublicMessageUpdateFormEvent {
  final String? content;

  const PublicMessageUpdateFormContentChangedEvent(this.content);

  @override
  List<Object?> get props => [content];
}
