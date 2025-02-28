import 'package:equatable/equatable.dart';

sealed class PublicMessageReportCreationFormEvent extends Equatable {
  const PublicMessageReportCreationFormEvent();

  @override
  List<Object?> get props => [];
}

class PublicMessageReportCreationFormReasonChangedEvent
    extends PublicMessageReportCreationFormEvent {
  final String? reason;

  const PublicMessageReportCreationFormReasonChangedEvent(this.reason);

  @override
  List<Object?> get props => [reason];
}
