import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/users/domain/usecases/get_users_public_data_usecase.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthBloc authBloc;

  final GetUsersPublicDataUsecase getUsersPublicDataUsecase =
      GetIt.instance<GetUsersPublicDataUsecase>();

  UserBloc({required this.authBloc}) : super(UsersLoaded(users: {})) {
    on<GetUserPublicDataEvent>(_getUserPublicData);
  }

  Future<void> _getUserPublicData(
      GetUserPublicDataEvent event, Emitter<UserState> emit) async {
    final currentState = state as UsersLoaded;

    final missingUserIds = event.userIds
        .where((userId) => !currentState.users.containsKey(userId))
        .toList();

    if (missingUserIds.isNotEmpty) {
      emit(UsersLoading());

      final resultGetUsersPublicDataUsecase =
          await getUsersPublicDataUsecase.call(
        userIds: missingUserIds,
      );

      resultGetUsersPublicDataUsecase.fold(
        (error) {
          if (error is ShouldLogoutError) {
            authBloc.add(
              AuthLogoutEvent(
                message: ErrorMessage(error.messageKey),
              ),
            );
          } else {
            emit(
              UsersLoaded(
                users: currentState.users,
                message: ErrorMessage(error.messageKey),
              ),
            );
          }
        },
        (users) {
          currentState.users.addAll(
            Map.fromEntries(
              users.map((u) => MapEntry(u.id, u)).toList(),
            ),
          );
          emit(
            UsersLoaded(
              users: currentState.users,
            ),
          );
        },
      );
    }
  }
}
