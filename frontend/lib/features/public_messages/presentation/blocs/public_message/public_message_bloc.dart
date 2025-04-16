import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message.dart';
import 'package:reallystick/features/public_messages/domain/entities/public_message_report.dart';
import 'package:reallystick/features/public_messages/domain/usecases/create_public_message_like_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/create_public_message_report_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/create_public_message_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/delete_public_message_like_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/delete_public_message_report_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/delete_public_message_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_liked_messages_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_message_parents_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_message_reports_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_public_messages_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_replies_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_user_message_reports_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/get_written_messages_usecase.dart';
import 'package:reallystick/features/public_messages/domain/usecases/update_public_message_usecase.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/public_message/public_message_states.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/reply/reply_events.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_bloc.dart';
import 'package:reallystick/features/public_messages/presentation/blocs/thread/thread_events.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';

class PublicMessageBloc extends Bloc<PublicMessageEvent, PublicMessageState> {
  final AuthBloc authBloc = GetIt.instance<AuthBloc>();
  final ProfileBloc profileBloc = GetIt.instance<ProfileBloc>();
  final UserBloc userBloc = GetIt.instance<UserBloc>();
  final ThreadBloc threadBloc = GetIt.instance<ThreadBloc>();
  final ReplyBloc replyBloc = GetIt.instance<ReplyBloc>();

  late StreamSubscription authBlocSubscription;

  final CreatePublicMessageLikeUsecase createPublicMessageLikeUsecase =
      GetIt.instance<CreatePublicMessageLikeUsecase>();
  final CreatePublicMessageReportUsecase createPublicMessageReportUsecase =
      GetIt.instance<CreatePublicMessageReportUsecase>();
  final CreatePublicMessageUsecase createPublicMessageUsecase =
      GetIt.instance<CreatePublicMessageUsecase>();
  final DeletePublicMessageLikeUsecase deletePublicMessageLikeUsecase =
      GetIt.instance<DeletePublicMessageLikeUsecase>();
  final DeletePublicMessageReportUsecase deletePublicMessageReportUsecase =
      GetIt.instance<DeletePublicMessageReportUsecase>();
  final DeletePublicMessageUsecase deletePublicMessageUsecase =
      GetIt.instance<DeletePublicMessageUsecase>();
  final GetLikedMessagesUsecase getLikedMessagesUsecase =
      GetIt.instance<GetLikedMessagesUsecase>();
  final GetMessageParentsUsecase getMessageParentsUsecase =
      GetIt.instance<GetMessageParentsUsecase>();
  final GetMessageReportsUsecase getMessageReportsUsecase =
      GetIt.instance<GetMessageReportsUsecase>();
  final GetPublicMessagesUsecase getPublicMessagesUsecase =
      GetIt.instance<GetPublicMessagesUsecase>();
  final GetRepliesUsecase getRepliesUsecase =
      GetIt.instance<GetRepliesUsecase>();
  final GetUserMessageReportsUsecase getUserMessageReportsUsecase =
      GetIt.instance<GetUserMessageReportsUsecase>();
  final GetWrittenMessagesUsecase getWrittenMessagesUsecase =
      GetIt.instance<GetWrittenMessagesUsecase>();
  final UpdatePublicMessageUsecase updatePublicMessageUsecase =
      GetIt.instance<UpdatePublicMessageUsecase>();

  PublicMessageBloc()
      : super(PublicMessagesLoaded(
          challengeId: null,
          habitId: null,
          threads: [],
          likedMessages: [],
          writtenMessages: [],
          userReportedMessages: [],
          allReportedMessages: [],
          userReports: [],
          allReports: [],
        )) {
    on<PublicMessageInitializeEvent>(
      initialize,
      transformer: sequential(),
    );
    on<CreatePublicMessageEvent>(createPublicMessage);
    on<UpdatePublicMessageEvent>(updatePublicMessage);
    on<DeletePublicMessageEvent>(deletePublicMessage);
    on<CreatePublicMessageLikeEvent>(createPublicMessageLike);
    on<DeletePublicMessageLikeEvent>(deletePublicMessageLike);
    on<CreatePublicMessageReportEvent>(createPublicMessageReport);
    on<DeletePublicMessageReportEvent>(deletePublicMessageReport);
    on<GetPublicMessagesEvent>(getPublicMessages);
    on<GetMessageReportsEvent>(getAllMessageReports);
    on<GetUserMessageReportsEvent>(getUserMessageReports);
    on<GetLikedMessagesEvent>(getLikedMessages);
    on<GetWrittenMessagesEvent>(getWrittenMessages);
  }

  Future<void> initialize(
    PublicMessageInitializeEvent event,
    Emitter<PublicMessageState> emit,
  ) async {
    final currentState = state as PublicMessagesLoaded;
    emit(PublicMessagesLoading());

    List<PublicMessage>? likedMessages = currentState.likedMessages;

    final result = await getLikedMessagesUsecase.call();

    likedMessages = await result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return [];
      },
      (likedMessages) {
        return likedMessages;
      },
    );

    List<PublicMessage>? writtenMessages = currentState.writtenMessages;

    final resultGetWrittenMessagesUsecase =
        await getWrittenMessagesUsecase.call();

    writtenMessages = resultGetWrittenMessagesUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return [];
      },
      (writtenMessages) {
        return writtenMessages;
      },
    );

    List<PublicMessage> threads = currentState.threads;

    if ((event.challengeId != null || event.habitId != null) &&
        (event.challengeId != currentState.challengeId ||
            event.habitId != currentState.habitId)) {
      final resultGetPublicMessagesUsecase =
          await getPublicMessagesUsecase.call(
        habitId: event.habitId,
        challengeId: event.challengeId,
      );

      threads = resultGetPublicMessagesUsecase.fold(
        (error) {
          if (error is ShouldLogoutError) {
            authBloc.add(
              AuthLogoutEvent(
                message: ErrorMessage(error.messageKey),
              ),
            );
          } else {
            emit(
              PublicMessagesLoaded(
                challengeId: currentState.challengeId,
                habitId: currentState.habitId,
                threads: currentState.threads,
                likedMessages: currentState.likedMessages,
                writtenMessages: currentState.writtenMessages,
                userReportedMessages: currentState.userReportedMessages,
                allReportedMessages: currentState.allReportedMessages,
                userReports: currentState.userReports,
                allReports: currentState.allReports,
                message: ErrorMessage(error.messageKey),
              ),
            );
          }
          return [];
        },
        (threads) {
          return threads;
        },
      );
    }

    List<PublicMessage> userReportedMessages =
        currentState.userReportedMessages;
    List<PublicMessageReport> userReports = currentState.userReports;

    final resultGetUserMessageReportsUsecase =
        await getUserMessageReportsUsecase.call();

    (userReports, userReportedMessages) =
        resultGetUserMessageReportsUsecase.fold((error) {
      if (error is ShouldLogoutError) {
        authBloc.add(
          AuthLogoutEvent(
            message: ErrorMessage(error.messageKey),
          ),
        );
      } else {
        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
            message: ErrorMessage(error.messageKey),
          ),
        );
      }
      return ([], []);
    }, (result) {
      return result;
    });

    List<PublicMessage> allReportedMessages = currentState.allReportedMessages;
    List<PublicMessageReport> allReports = currentState.allReports;

    if (profileBloc.state is ProfileAuthenticated &&
        profileBloc.state.profile!.isAdmin) {
      final resultGetMessageReportsUsecase =
          await getMessageReportsUsecase.call();

      (allReports, allReportedMessages) =
          resultGetMessageReportsUsecase.fold((error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
        return ([], []);
      }, (result) {
        return result;
      });
    }

    List<PublicMessage> messagesToGetUserPublicDataFor =
        List<PublicMessage>.from(likedMessages);
    messagesToGetUserPublicDataFor.addAll(writtenMessages);
    messagesToGetUserPublicDataFor.addAll(threads);
    messagesToGetUserPublicDataFor.addAll(userReportedMessages);
    messagesToGetUserPublicDataFor.addAll(allReportedMessages);

    // Check if we are missing some user info
    userBloc.add(
      GetUserPublicDataEvent(
        userIds: messagesToGetUserPublicDataFor.map((t) => t.creator).toList(),
        username: null,
      ),
    );

    emit(
      PublicMessagesLoaded(
        challengeId: event.challengeId,
        habitId: event.habitId,
        threads: threads,
        likedMessages: likedMessages,
        writtenMessages: writtenMessages,
        userReportedMessages: userReportedMessages,
        allReportedMessages: allReportedMessages,
        userReports: userReports,
        allReports: allReports,
      ),
    );
  }

  Future<void> getPublicMessages(
      GetPublicMessagesEvent event, Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;
    emit(PublicMessagesLoading());

    final resultGetPublicMessagesUsecase = await getPublicMessagesUsecase.call(
      habitId: event.habitId,
      challengeId: event.challengeId,
    );

    resultGetPublicMessagesUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (threads) {
        // Check if we are missing some user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: threads.map((t) => t.creator).toList(),
            username: null,
          ),
        );

        emit(
          PublicMessagesLoaded(
            challengeId: event.challengeId,
            habitId: event.habitId,
            threads: threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
          ),
        );
      },
    );
  }

  Future<void> createPublicMessage(
      CreatePublicMessageEvent event, Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final resultCreatePublicMessagesUsecase =
        await createPublicMessageUsecase.call(
      habitId: event.habitId,
      challengeId: event.challengeId,
      content: event.content,
      repliesTo: event.repliesTo,
      threadId: event.threadId,
    );

    resultCreatePublicMessagesUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (message) {
        // Fetch missing user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: [message.creator],
            username: null,
          ),
        );

        List<PublicMessage> updatedThreads = List.from(currentState.threads);

        if (event.repliesTo != null) {
          replyBloc.add(AddNewReplyMessage(message: message));
          threadBloc.add(AddNewThreadMessage(message: message));

          int replyIndex =
              updatedThreads.indexWhere((m) => m.id == event.repliesTo);
          if (replyIndex != -1) {
            updatedThreads[replyIndex] = updatedThreads[replyIndex].copyWith(
                replyCount: updatedThreads[replyIndex].replyCount + 1);
          }
        } else {
          updatedThreads.add(message);
        }

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: updatedThreads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
          ),
        );
      },
    );
  }

  Future<void> updatePublicMessage(
      UpdatePublicMessageEvent event, Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final resultUpdatePublicMessagesUsecase =
        await updatePublicMessageUsecase.call(
      messageId: event.messageId,
      content: event.content,
    );

    resultUpdatePublicMessagesUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (message) {
        // Check if we are missing some user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: [message.creator],
            username: null,
          ),
        );

        replyBloc.add(
          UpdateReplyMessage(
            message: message,
          ),
        );
        threadBloc.add(
          UpdateThreadMessage(
            message: message,
          ),
        );

        int threadIndex =
            currentState.threads.indexWhere((m) => m.id == message.id);
        if (threadIndex != -1) {
          currentState.threads[threadIndex] = message;
        }

        int writtenMessagesIndex =
            currentState.writtenMessages.indexWhere((m) => m.id == message.id);
        if (writtenMessagesIndex != -1) {
          currentState.writtenMessages[writtenMessagesIndex] = message;
        }

        int likedMessagesIndex =
            currentState.likedMessages.indexWhere((m) => m.id == message.id);
        if (likedMessagesIndex != -1) {
          currentState.likedMessages[likedMessagesIndex] = message;
        }

        int reportedMessagesIndex = currentState.userReportedMessages
            .indexWhere((m) => m.id == message.id);
        if (reportedMessagesIndex != -1) {
          currentState.userReportedMessages[reportedMessagesIndex] = message;
        }

        int allReportedMessagesIndex = currentState.allReportedMessages
            .indexWhere((m) => m.id == message.id);
        if (allReportedMessagesIndex != -1) {
          currentState.allReportedMessages[allReportedMessagesIndex] = message;
        }

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
          ),
        );
      },
    );
  }

  Future<void> deletePublicMessage(
      DeletePublicMessageEvent event, Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final resultDeletePublicMessagesUsecase =
        await deletePublicMessageUsecase.call(
      messageId: event.message.id,
      deletedByAdmin: event.deletedByAdmin,
    );

    resultDeletePublicMessagesUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        if (event.message.repliesTo != null) {
          int replyIndex = currentState.threads
              .indexWhere((m) => m.id == event.message.repliesTo);
          if (replyIndex != -1) {
            currentState.threads[replyIndex].replyCount -= 1;
          }
        }

        int threadIndex =
            currentState.threads.indexWhere((m) => m.id == event.message.id);
        if (threadIndex != -1) {
          currentState.threads[threadIndex].deletedByAdmin =
              event.deletedByAdmin;
          currentState.threads[threadIndex].deletedByCreator =
              !event.deletedByAdmin;
        }

        int writtenMessagesIndex = currentState.writtenMessages
            .indexWhere((m) => m.id == event.message.id);
        if (writtenMessagesIndex != -1) {
          currentState.writtenMessages[writtenMessagesIndex].deletedByAdmin =
              event.deletedByAdmin;
          currentState.writtenMessages[writtenMessagesIndex].deletedByCreator =
              !event.deletedByAdmin;
        }

        int likedMessagesIndex = currentState.likedMessages
            .indexWhere((m) => m.id == event.message.id);
        if (likedMessagesIndex != -1) {
          currentState.likedMessages[likedMessagesIndex].deletedByAdmin =
              event.deletedByAdmin;
          currentState.likedMessages[likedMessagesIndex].deletedByCreator =
              !event.deletedByAdmin;
        }

        int reportedMessagesIndex = currentState.userReportedMessages
            .indexWhere((m) => m.id == event.message.id);
        if (reportedMessagesIndex != -1) {
          currentState.userReportedMessages[reportedMessagesIndex]
              .deletedByAdmin = event.deletedByAdmin;
          currentState.userReportedMessages[reportedMessagesIndex]
              .deletedByCreator = !event.deletedByAdmin;
        }

        int allReportedMessagesIndex = currentState.allReportedMessages
            .indexWhere((m) => m.id == event.message.id);
        if (allReportedMessagesIndex != -1) {
          currentState.allReportedMessages[allReportedMessagesIndex]
              .deletedByAdmin = event.deletedByAdmin;
          currentState.allReportedMessages[allReportedMessagesIndex]
              .deletedByCreator = !event.deletedByAdmin;
        }

        replyBloc.add(
          DeleteReplyMessage(
            messageId: event.message.id,
            deletedByAdmin: event.deletedByAdmin,
          ),
        );
        threadBloc.add(
          DeleteThreadMessage(
            messageId: event.message.id,
            deletedByAdmin: event.deletedByAdmin,
          ),
        );

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
            message: SuccessMessage("publicMessageDeletionSuccessful"),
          ),
        );
      },
    );
  }

  Future<void> createPublicMessageLike(CreatePublicMessageLikeEvent event,
      Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final resultCreatePublicMessageLikeUsecase =
        await createPublicMessageLikeUsecase.call(
      messageId: event.message.id,
    );

    resultCreatePublicMessageLikeUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        replyBloc.add(
          AddLikeOnReplyMessage(
            messageId: event.message.id,
          ),
        );
        threadBloc.add(
          AddLikeOnThreadMessage(
            messageId: event.message.id,
          ),
        );

        int threadIndex =
            currentState.threads.indexWhere((m) => m.id == event.message.id);
        if (threadIndex != -1) {
          currentState.threads[threadIndex].likeCount += 1;
        }

        int writtenMessagesIndex = currentState.writtenMessages
            .indexWhere((m) => m.id == event.message.id);
        if (writtenMessagesIndex != -1) {
          currentState.writtenMessages[writtenMessagesIndex].likeCount += 1;
        }

        int likedMessagesIndex = currentState.likedMessages
            .indexWhere((m) => m.id == event.message.id);
        if (likedMessagesIndex != -1) {
          currentState.likedMessages[likedMessagesIndex].likeCount += 1;
        } else {
          currentState.likedMessages.add(event.message);
        }

        int reportedMessagesIndex = currentState.userReportedMessages
            .indexWhere((m) => m.id == event.message.id);
        if (reportedMessagesIndex != -1) {
          currentState.userReportedMessages[reportedMessagesIndex].likeCount +=
              1;
        }

        int allReportedMessagesIndex = currentState.allReportedMessages
            .indexWhere((m) => m.id == event.message.id);
        if (allReportedMessagesIndex != -1) {
          currentState
              .allReportedMessages[allReportedMessagesIndex].likeCount += 1;
        }

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
          ),
        );
      },
    );
  }

  Future<void> deletePublicMessageLike(DeletePublicMessageLikeEvent event,
      Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final resultDeletePublicMessageLikeUsecase =
        await deletePublicMessageLikeUsecase.call(
      messageId: event.messageId,
    );

    resultDeletePublicMessageLikeUsecase.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        replyBloc.add(
          DeleteLikeOnReplyMessage(
            messageId: event.messageId,
          ),
        );
        threadBloc.add(
          DeleteLikeOnThreadMessage(
            messageId: event.messageId,
          ),
        );

        int threadIndex =
            currentState.threads.indexWhere((m) => m.id == event.messageId);
        if (threadIndex != -1) {
          currentState.threads[threadIndex].likeCount -= 1;
        }

        int writtenMessagesIndex = currentState.writtenMessages
            .indexWhere((m) => m.id == event.messageId);
        if (writtenMessagesIndex != -1) {
          currentState.writtenMessages[writtenMessagesIndex].likeCount -= 1;
        }

        currentState.likedMessages.removeWhere((m) => m.id == event.messageId);

        int reportedMessagesIndex = currentState.userReportedMessages
            .indexWhere((m) => m.id == event.messageId);
        if (reportedMessagesIndex != -1) {
          currentState.userReportedMessages[reportedMessagesIndex].likeCount -=
              1;
        }
        int allReportedMessagesIndex = currentState.allReportedMessages
            .indexWhere((m) => m.id == event.messageId);
        if (allReportedMessagesIndex != -1) {
          currentState
              .allReportedMessages[allReportedMessagesIndex].likeCount -= 1;
        }

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
          ),
        );
      },
    );
  }

  Future<void> createPublicMessageReport(CreatePublicMessageReportEvent event,
      Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final result = await createPublicMessageReportUsecase.call(
      messageId: event.message.id,
      reason: event.reason,
    );

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
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (report) {
        currentState.userReports.add(report);
        currentState.allReports.add(report);
        currentState.allReportedMessages.add(event.message);
        currentState.userReportedMessages.add(event.message);

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
            message: SuccessMessage("publicMessageReportCreationSuccessful"),
          ),
        );
      },
    );
  }

  Future<void> deletePublicMessageReport(DeletePublicMessageReportEvent event,
      Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final result = await deletePublicMessageReportUsecase.call(
      messageReportId: event.messageReportId,
    );

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
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        currentState.userReports
            .removeWhere((report) => report.id == event.messageReportId);

        currentState.allReports
            .removeWhere((report) => report.id == event.messageReportId);

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
          ),
        );
      },
    );
  }

  Future<void> getAllMessageReports(
      GetMessageReportsEvent event, Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final result = await getMessageReportsUsecase.call();

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
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (result) {
        final (reports, messages) = result;

        // Check if we are missing some user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: messages.map((t) => t.creator).toList(),
            username: null,
          ),
        );

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: messages,
            userReports: currentState.userReports,
            allReports: reports,
          ),
        );
      },
    );
  }

  Future<void> getUserMessageReports(GetUserMessageReportsEvent event,
      Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final result = await getUserMessageReportsUsecase.call();

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
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (result) {
        final (reports, messages) = result;

        // Check if we are missing some user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: messages.map((t) => t.creator).toList(),
            username: null,
          ),
        );

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: messages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: reports,
            allReports: currentState.allReports,
          ),
        );
      },
    );
  }

  Future<void> getLikedMessages(
      GetLikedMessagesEvent event, Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final result = await getLikedMessagesUsecase.call();

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
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (likedMessages) {
        // Check if we are missing some user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: likedMessages.map((t) => t.creator).toList(),
            username: null,
          ),
        );

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: likedMessages,
            writtenMessages: currentState.writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
          ),
        );
      },
    );
  }

  Future<void> getWrittenMessages(
      GetWrittenMessagesEvent event, Emitter<PublicMessageState> emit) async {
    final currentState = state as PublicMessagesLoaded;

    final result = await getWrittenMessagesUsecase.call();

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
            PublicMessagesLoaded(
              challengeId: currentState.challengeId,
              habitId: currentState.habitId,
              threads: currentState.threads,
              likedMessages: currentState.likedMessages,
              writtenMessages: currentState.writtenMessages,
              userReportedMessages: currentState.userReportedMessages,
              allReportedMessages: currentState.allReportedMessages,
              userReports: currentState.userReports,
              allReports: currentState.allReports,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (writtenMessages) {
        // Check if we are missing some user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: writtenMessages.map((t) => t.creator).toList(),
            username: null,
          ),
        );

        emit(
          PublicMessagesLoaded(
            challengeId: currentState.challengeId,
            habitId: currentState.habitId,
            threads: currentState.threads,
            likedMessages: currentState.likedMessages,
            writtenMessages: writtenMessages,
            userReportedMessages: currentState.userReportedMessages,
            allReportedMessages: currentState.allReportedMessages,
            userReports: currentState.userReports,
            allReports: currentState.allReports,
          ),
        );
      },
    );
  }
}
