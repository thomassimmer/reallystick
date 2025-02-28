import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/users/domain/usecases/get_users_public_data_by_id_usecase.dart';
import 'package:reallystick/features/users/domain/usecases/get_users_public_data_by_username_usecase.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_states.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthBloc authBloc = GetIt.instance<AuthBloc>();

  final GetUsersPublicDataByIdUsecase getUsersPublicDataByIdUsecase =
      GetIt.instance<GetUsersPublicDataByIdUsecase>();
  final GetUsersPublicDataByUsernameUsecase
      getUsersPublicDataByUsernameUsecase =
      GetIt.instance<GetUsersPublicDataByUsernameUsecase>();

  UserBloc() : super(UsersLoaded(users: {}, user: null)) {
    on<GetUserPublicDataEvent>(_getUserPublicData, transformer: sequential());
  }

  Future<void> _getUserPublicData(
      GetUserPublicDataEvent event, Emitter<UserState> emit) async {
    final currentState = state as UsersLoaded;

    if (event.userIds != null) {
      final missingUserIds = event.userIds!
          .where((userId) => !currentState.users.containsKey(userId))
          .toList();

      if (missingUserIds.isNotEmpty) {
        final resultGetUsersPublicDataUsecase =
            await getUsersPublicDataByIdUsecase.call(
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
                  user: currentState.user,
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
                user: currentState.user,
              ),
            );
          },
        );
      }
    }

    if (event.username != null) {
      final user = currentState.users.values
          .where((u) => u.username == event.username)
          .firstOrNull;

      if (user != null) {
        emit(
          UsersLoaded(
            users: currentState.users,
            user: user,
          ),
        );
      } else {
        emit(UsersLoading());

        final resultGetUsersPublicDataUsecase =
            await getUsersPublicDataByUsernameUsecase.call(
          username: event.username!,
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
                  user: currentState.user,
                  users: currentState.users,
                  message: ErrorMessage(error.messageKey),
                ),
              );
            }
          },
          (user) {
            if (user != null) {
              currentState.users.addEntries([MapEntry(user.id, user)]);
            }

            emit(
              UsersLoaded(
                user: user,
                users: currentState.users,
              ),
            );
          },
        );
      }
    }
  }
}
