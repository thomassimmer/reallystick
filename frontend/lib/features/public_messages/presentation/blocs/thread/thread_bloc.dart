import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_message_parents_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_replies_usecase.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';

class ThreadBloc extends Bloc<ThreadEvent, ThreadState>
    with WidgetsBindingObserver {
  final AuthBloc authBloc = GetIt.instance<AuthBloc>();
  final UserBloc userBloc = GetIt.instance<UserBloc>();

  final GetRepliesUsecase getRepliesUsecase =
      GetIt.instance<GetRepliesUsecase>();
  final GetMessageParentsUsecase getMessageParentsUsecase =
      GetIt.instance<GetMessageParentsUsecase>();

  ThreadBloc() : super(ThreadLoaded(replies: [], threadId: null)) {
    on<InitializeThreadEvent>(initialize);
    on<AddNewThreadMessage>(addNewMessage);
    on<UpdateThreadMessage>(updateMessage);
    on<DeleteThreadMessage>(deleteMessage);
    on<AddLikeOnThreadMessage>(addLike);
    on<DeleteLikeOnThreadMessage>(deleteLike);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;

    if (state == AppLifecycleState.resumed) {
      if (this.state is ThreadLoaded) {
        final currentState = this.state as ThreadLoaded;
        if (currentState.threadId != null) {
          add(InitializeThreadEvent(threadId: currentState.threadId!));
        }
      }
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  Future<void> initialize(
      InitializeThreadEvent event, Emitter<ThreadState> emit) async {
    final currentState = state as ThreadLoaded;
    emit(ThreadLoading());

    final result = await getRepliesUsecase.call(messageId: event.threadId);

    result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            ThreadLoaded(
              replies: currentState.replies,
              threadId: currentState.threadId,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (replies) {
        // Check if we are missing some user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: replies.map((t) => t.creator).toList(),
          ),
        );

        emit(
          ThreadLoaded(
            replies: replies,
            threadId: event.threadId,
          ),
        );
      },
    );
  }

  Future<void> addNewMessage(
      AddNewThreadMessage event, Emitter<ThreadState> emit) async {
    final currentState = state as ThreadLoaded;
    emit(ThreadLoading());

    List<PublicMessage>? replies = currentState.replies;

    replies.add(event.message);

    if (event.message.repliesTo != null) {
      int replyIndex =
          replies.indexWhere((m) => m.id == event.message.repliesTo);
      if (replyIndex != -1) {
        replies[replyIndex].replyCount += 1;
      }
    }

    emit(
      ThreadLoaded(
        replies: replies,
        threadId: currentState.threadId,
      ),
    );
  }

  Future<void> updateMessage(
      UpdateThreadMessage event, Emitter<ThreadState> emit) async {
    final currentState = state as ThreadLoaded;
    emit(ThreadLoading());

    int replyIndex =
        currentState.replies.indexWhere((m) => m.id == event.message.id);
    if (replyIndex != -1) {
      currentState.replies[replyIndex] = event.message;
    }

    emit(
      ThreadLoaded(
        replies: currentState.replies,
        threadId: currentState.threadId,
      ),
    );
  }

  Future<void> deleteMessage(
      DeleteThreadMessage event, Emitter<ThreadState> emit) async {
    final currentState = state as ThreadLoaded;
    emit(ThreadLoading());

    PublicMessage? messageToDelete;

    int messageToDeleteIndexInReplies =
        currentState.replies.indexWhere((m) => m.id == event.messageId);
    if (messageToDeleteIndexInReplies != -1) {
      messageToDelete = currentState.replies[messageToDeleteIndexInReplies];
    }

    if (messageToDelete != null && messageToDelete.repliesTo != null) {
      int messageRepliedToIndexInReplies = currentState.replies
          .indexWhere((m) => m.id == messageToDelete!.repliesTo);
      if (messageRepliedToIndexInReplies != -1) {
        currentState.replies[messageRepliedToIndexInReplies].replyCount -= 1;
      }
    }

    if (messageToDeleteIndexInReplies != -1) {
      currentState.replies[messageToDeleteIndexInReplies].deletedByAdmin =
          event.deletedByAdmin;
      currentState.replies[messageToDeleteIndexInReplies].deletedByCreator =
          !event.deletedByAdmin;
    }

    emit(
      ThreadLoaded(
        replies: currentState.replies,
        threadId: currentState.threadId,
      ),
    );
  }

  Future<void> addLike(
      AddLikeOnThreadMessage event, Emitter<ThreadState> emit) async {
    final currentState = state as ThreadLoaded;
    emit(ThreadLoading());

    int replyIndex =
        currentState.replies.indexWhere((m) => m.id == event.messageId);
    if (replyIndex != -1) {
      currentState.replies[replyIndex].likeCount += 1;
    }

    emit(
      ThreadLoaded(
        replies: currentState.replies,
        threadId: currentState.threadId,
      ),
    );
  }

  Future<void> deleteLike(
      DeleteLikeOnThreadMessage event, Emitter<ThreadState> emit) async {
    final currentState = state as ThreadLoaded;
    emit(ThreadLoading());

    int replyIndex =
        currentState.replies.indexWhere((m) => m.id == event.messageId);
    if (replyIndex != -1) {
      currentState.replies[replyIndex].likeCount -= 1;
    }

    emit(
      ThreadLoaded(
        replies: currentState.replies,
        threadId: currentState.threadId,
      ),
    );
  }
}
