import 'package:bloc/bloc.dart';
import 'package:formz/formz.dart';
import 'package:reallystick/core/validators/challenge_datetime.dart';
import 'package:reallystick/core/validators/challenge_name.dart';
import 'package:reallystick/core/validators/description.dart';
import 'package:reallystick/core/validators/icon.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_Update/challenge_Update_events.dart';
import 'package:reallystick/features/challenges/presentation/blocs/challenge_Update/challenge_Update_states.dart';

class ChallengeUpdateFormBloc
    extends Bloc<ChallengeUpdateFormEvent, ChallengeUpdateFormState> {
  ChallengeUpdateFormBloc() : super(const ChallengeUpdateFormState()) {
    on<ChallengeUpdateFormNameChangedEvent>(_nameChanged);
    on<ChallengeUpdateFormDescriptionChangedEvent>(_descriptionChanged);
    on<ChallengeUpdateFormIconChangedEvent>(_iconChanged);
    on<ChallengeUpdateFormStartDateChangedEvent>(_startDateChanged);
  }

  Future<void> _nameChanged(
      ChallengeUpdateFormNameChangedEvent event, Emitter emit) async {
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
      ChallengeUpdateFormDescriptionChangedEvent event, Emitter emit) async {
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
      ChallengeUpdateFormIconChangedEvent event, Emitter emit) async {
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
      ChallengeUpdateFormStartDateChangedEvent event, Emitter emit) async {
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
