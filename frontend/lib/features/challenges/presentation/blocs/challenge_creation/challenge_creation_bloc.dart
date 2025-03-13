import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/challenge_datetime.dart';
import 'package:reallystick/core/validators/challenge_name.dart';
import 'package:reallystick/core/validators/description.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_creation/challenge_creation_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_creation/challenge_creation_states.dart';

class ChallengeCreationFormBloc
    extends Bloc<ChallengeCreationFormEvent, ChallengeCreationFormState> {
  ChallengeCreationFormBloc() : super(const ChallengeCreationFormState()) {
    on<ChallengeCreationFormNameChangedEvent>(_nameChanged);
    on<ChallengeCreationFormDescriptionChangedEvent>(_descriptionChanged);
    on<ChallengeCreationFormIconChangedEvent>(_iconChanged);
    on<ChallengeCreationFormStartDateChangedEvent>(_startDateChanged);
  }

  Future<void> _nameChanged(
      ChallengeCreationFormNameChangedEvent event, Emitter emit) async {
    final Map<String, ChallengeNameValidator> nameMap = {};

    if (event.name.entries.isEmpty) {
      nameMap['en'] = ChallengeNameValidator.dirty('No translation entered');
    } else {
      for (final entry in event.name.entries) {
        nameMap[entry.key] = ChallengeNameValidator.dirty(entry.value);
      }
    }

    emit(
      state.copyWith(
        name: nameMap,
        isValid: Formz.validate([
          ...state.description.values,
          state.icon,
          state.startDate,
        ]),
      ),
    );
  }

  Future<void> _descriptionChanged(
      ChallengeCreationFormDescriptionChangedEvent event, Emitter emit) async {
    final Map<String, DescriptionValidator> descriptionMap = {};

    if (event.description.entries.isEmpty) {
      descriptionMap['en'] =
          DescriptionValidator.dirty('No translation entered');
    } else {
      for (final entry in event.description.entries) {
        descriptionMap[entry.key] = DescriptionValidator.dirty(entry.value);
      }
    }

    emit(
      state.copyWith(
        description: descriptionMap,
        isValid: Formz.validate([
          ...state.name.values,
          state.icon,
          state.startDate,
        ]),
      ),
    );
  }

  Future<void> _iconChanged(
      ChallengeCreationFormIconChangedEvent event, Emitter emit) async {
    final icon = IconValidator.dirty(event.icon);

    emit(
      state.copyWith(
        icon: icon,
        isValid: Formz.validate([
          ...state.name.values,
          ...state.description.values,
          state.startDate,
        ]),
      ),
    );
  }

  Future<void> _startDateChanged(
      ChallengeCreationFormStartDateChangedEvent event, Emitter emit) async {
    final startDate = ChallengeDatetime.dirty(event.startDate);

    emit(
      state.copyWith(
        startDate: startDate,
        isValid: Formz.validate([
          ...state.name.values,
          ...state.description.values,
          state.icon,
        ]),
      ),
    );
  }
}
