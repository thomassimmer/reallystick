import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_message_parents_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_message_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_replies_usecase.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';

class ReplyBloc extends Bloc<ReplyEvent, ReplyState>
    with WidgetsBindingObserver {
  final AuthBloc authBloc = GetIt.instance<AuthBloc>();
  final UserBloc userBloc = GetIt.instance<UserBloc>();

  final GetRepliesUsecase getRepliesUsecase =
      GetIt.instance<GetRepliesUsecase>();
  final GetMessageParentsUsecase getMessageParentsUsecase =
      GetIt.instance<GetMessageParentsUsecase>();
  final GetMessageUsecase getMessageUsecase =
      GetIt.instance<GetMessageUsecase>();

  ReplyBloc()
      : super(ReplyLoaded(
          reply: null,
          parents: [],
          replies: [],
        )) {
    on<InitializeReplyEvent>(initialize);
    on<AddNewReplyMessage>(addNewMessage);
    on<UpdateReplyMessage>(updateMessage);
    on<DeleteReplyMessage>(deleteMessage);
    on<AddLikeOnReplyMessage>(addLike);
    on<DeleteLikeOnReplyMessage>(deleteLike);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (this.state is ReplyLoaded) {
        final currentState = this.state as ReplyLoaded;
        if (currentState.reply != null) {
          add(InitializeReplyEvent(messageId: currentState.reply!.id));
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
      InitializeReplyEvent event, Emitter<ReplyState> emit) async {
    final currentState = state as ReplyLoaded;
    emit(ReplyLoading());

    final resultGetMessageParentsUsecase =
        await getMessageParentsUsecase.call(messageId: event.messageId);

    List<PublicMessage> parents = resultGetMessageParentsUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            ReplyLoaded(
              replies: currentState.replies,
              parents: currentState.parents,
              reply: currentState.reply,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return [];
      },
      (parents) {
        return parents;
      },
    );

    final resultGetRepliesUsecase =
        await getRepliesUsecase.call(messageId: event.messageId);

    List<PublicMessage> replies = resultGetRepliesUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            ReplyLoaded(
              replies: currentState.replies,
              parents: currentState.parents,
              reply: currentState.reply,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return [];
      },
      (replies) {
        return replies;
      },
    );

    final resultGetMessageUsecase =
        await getMessageUsecase.call(messageId: event.messageId);

    final reply = resultGetMessageUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            ReplyLoaded(
              replies: currentState.replies,
              parents: currentState.parents,
              reply: currentState.reply,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return null;
      },
      (reply) {
        return reply;
      },
    );

    List<PublicMessage> messagesToGetUserPublicDataFor =
        List<PublicMessage>.from(parents);
    messagesToGetUserPublicDataFor.addAll(replies);

    if (reply != null) {
      messagesToGetUserPublicDataFor.add(reply);
    }

    // Check if we are missing some user info
    userBloc.add(
      GetUserPublicDataEvent(
        userIds: messagesToGetUserPublicDataFor.map((t) => t.creator).toList(),
        username: null,
      ),
    );

    emit(
      ReplyLoaded(
        replies: replies,
        parents: parents,
        reply: reply,
      ),
    );
  }

  Future<void> addNewMessage(
      AddNewReplyMessage event, Emitter<ReplyState> emit) async {
    final currentState = state as ReplyLoaded;
    emit(ReplyLoading());

    List<PublicMessage>? replies = currentState.replies;

    replies.add(event.message);

    if (event.message.repliesTo != null) {
      int replyIndex =
          replies.indexWhere((m) => m.id == event.message.repliesTo);
      if (replyIndex != -1) {
        replies[replyIndex].replyCount += 1;
      }

      if (currentState.reply != null) {
        if (currentState.reply!.id == event.message.repliesTo) {
          currentState.reply!.replyCount += 1;
        }
      }
    }

    emit(
      ReplyLoaded(
        replies: replies,
        parents: currentState.parents,
        reply: currentState.reply,
      ),
    );
  }

  Future<void> updateMessage(
      UpdateReplyMessage event, Emitter<ReplyState> emit) async {
    final currentState = state as ReplyLoaded;
    emit(ReplyLoading());

    int replyIndex =
        currentState.replies.indexWhere((m) => m.id == event.message.id);
    if (replyIndex != -1) {
      currentState.replies[replyIndex] = event.message;
    }

    int parentIndex =
        currentState.parents.indexWhere((m) => m.id == event.message.id);
    if (parentIndex != -1) {
      currentState.parents[parentIndex] = event.message;
    }

    PublicMessage? reply = currentState.reply;

    if (reply != null) {
      if (reply.id == event.message.id) {
        reply = event.message;
      }
    }

    emit(
      ReplyLoaded(
        replies: currentState.replies,
        parents: currentState.parents,
        reply: reply,
      ),
    );
  }

  Future<void> deleteMessage(
      DeleteReplyMessage event, Emitter<ReplyState> emit) async {
    final currentState = state as ReplyLoaded;
    emit(ReplyLoading());

    PublicMessage? messageToDelete;

    int messageToDeleteIndexInReplies =
        currentState.replies.indexWhere((m) => m.id == event.messageId);
    if (messageToDeleteIndexInReplies != -1) {
      messageToDelete = currentState.replies[messageToDeleteIndexInReplies];
    }

    int messageToDeleteIndexInParents =
        currentState.parents.indexWhere((m) => m.id == event.messageId);
    if (messageToDeleteIndexInParents != -1) {
      messageToDelete = currentState.parents[messageToDeleteIndexInParents];
    }

    if (currentState.reply != null) {
      if (currentState.reply!.id == event.messageId) {
        messageToDelete = currentState.reply;
      }
    }

    if (messageToDelete != null && messageToDelete.repliesTo != null) {
      int messageRepliedToIndexInReplies = currentState.replies
          .indexWhere((m) => m.id == messageToDelete!.repliesTo);
      if (messageRepliedToIndexInReplies != -1) {
        currentState.replies[messageRepliedToIndexInReplies].replyCount -= 1;
      }

      int messageRepliedToIndexInParents = currentState.parents
          .indexWhere((m) => m.id == messageToDelete!.repliesTo);
      if (messageRepliedToIndexInParents != -1) {
        currentState.parents[messageRepliedToIndexInParents].replyCount -= 1;
      }

      if (currentState.reply != null) {
        if (currentState.reply!.id == messageToDelete.repliesTo) {
          currentState.reply!.replyCount -= 1;
        }
      }
    }

    if (messageToDeleteIndexInReplies != -1) {
      currentState.replies[messageToDeleteIndexInReplies].deletedByAdmin =
          event.deletedByAdmin;
      currentState.replies[messageToDeleteIndexInReplies].deletedByCreator =
          !event.deletedByAdmin;
    }
    if (messageToDeleteIndexInParents != -1) {
      currentState.parents[messageToDeleteIndexInParents].deletedByAdmin =
          event.deletedByAdmin;
      currentState.parents[messageToDeleteIndexInParents].deletedByCreator =
          !event.deletedByAdmin;
    }

    PublicMessage? reply = currentState.reply;

    if (reply != null) {
      if (reply.id == event.messageId) {
        reply.deletedByAdmin = event.deletedByAdmin;
        reply.deletedByCreator = !event.deletedByAdmin;
      }
    }

    emit(
      ReplyLoaded(
        replies: currentState.replies,
        parents: currentState.parents,
        reply: reply,
      ),
    );
  }

  void addLike(
    AddLikeOnReplyMessage event,
    Emitter<ReplyState> emit,
  ) {
    if (state is! ReplyLoaded) return;

    final currentState = state as ReplyLoaded;

    // Create new copies of lists
    final updatedReplies = List<PublicMessage>.from(currentState.replies);
    final updatedParents = List<PublicMessage>.from(currentState.parents);
    PublicMessage? updatedReply = currentState.reply;

    int replyIndex = updatedReplies.indexWhere((m) => m.id == event.messageId);
    if (replyIndex != -1) {
      updatedReplies[replyIndex] = updatedReplies[replyIndex].copyWith(
        likeCount: updatedReplies[replyIndex].likeCount + 1,
      );
    }

    int parentIndex = updatedParents.indexWhere((m) => m.id == event.messageId);
    if (parentIndex != -1) {
      updatedParents[parentIndex] = updatedParents[parentIndex].copyWith(
        likeCount: updatedParents[parentIndex].likeCount + 1,
      );
    }

    if (updatedReply != null && updatedReply.id == event.messageId) {
      updatedReply =
          updatedReply.copyWith(likeCount: updatedReply.likeCount + 1);
    }

    emit(
      ReplyLoaded(
        replies: updatedReplies,
        parents: updatedParents,
        reply: updatedReply,
      ),
    );
  }

  void deleteLike(
    DeleteLikeOnReplyMessage event,
    Emitter<ReplyState> emit,
  ) {
    if (state is! ReplyLoaded) return;

    final currentState = state as ReplyLoaded;

    // Create new copies of lists
    final updatedReplies = List<PublicMessage>.from(currentState.replies);
    final updatedParents = List<PublicMessage>.from(currentState.parents);
    PublicMessage? updatedReply = currentState.reply;

    int replyIndex = updatedReplies.indexWhere((m) => m.id == event.messageId);
    if (replyIndex != -1 && updatedReplies[replyIndex].likeCount > 0) {
      updatedReplies[replyIndex] = updatedReplies[replyIndex].copyWith(
        likeCount: updatedReplies[replyIndex].likeCount - 1,
      );
    }

    int parentIndex = updatedParents.indexWhere((m) => m.id == event.messageId);
    if (parentIndex != -1 && updatedParents[parentIndex].likeCount > 0) {
      updatedParents[parentIndex] = updatedParents[parentIndex].copyWith(
        likeCount: updatedParents[parentIndex].likeCount - 1,
      );
    }

    if (updatedReply != null &&
        updatedReply.id == event.messageId &&
        updatedReply.likeCount > 0) {
      updatedReply =
          updatedReply.copyWith(likeCount: updatedReply.likeCount - 1);
    }

    emit(
      ReplyLoaded(
        replies: updatedReplies,
        parents: updatedParents,
        reply: updatedReply,
      ),
    );
  }
}
