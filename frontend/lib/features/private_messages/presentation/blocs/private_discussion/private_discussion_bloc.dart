import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/ui/colors.dart';
import 'package:reallystick/features/auth/data/storage/private_message_key_storage.dart';
import 'package:reallystick/features/auth/data/storage/token_storage.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/private_messages/data/models/private_message.dart';
import 'package:reallystick/features/private_messages/domain/entities/private_discussion.dart';
import 'package:reallystick/features/private_messages/domain/usecases/create_private_discussion_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/decrypt_message_using_aes_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/decrypt_symmetric_key_with_rsa_private_key_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/get_private_discussions.dart';
import 'package:reallystick/features/private_messages/domain/usecases/update_private_discussion_participation_usecase.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_discussion/private_discussion_states.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_bloc.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_events.dart';
import 'package:reallystick/features/private_messages/presentation/blocs/private_message/private_message_states.dart';
import 'package:reallystick/features/private_messages/presentation/helpers/websocket_service.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_bloc.dart';
import 'package:reallystick/features/profile/presentation/blocs/profile/profile_states.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_bloc.dart';
import 'package:reallystick/features/users/presentation/blocs/user/user_events.dart';

class PrivateDiscussionBloc
    extends Bloc<PrivateDiscussionEvent, PrivateDiscussionState> {
  final AuthBloc authBloc;
  final UserBloc userBloc;
  final ProfileBloc profileBloc;
  final PrivateMessageBloc privateMessageBloc;
  final WebSocketService webSocketService;

  late StreamSubscription profileBlocSubscription;
  late StreamSubscription privateMessageBlocSubscription;

  final GetPrivateDiscussionsUsecase getPrivateDiscussionsUsecase =
      GetIt.instance<GetPrivateDiscussionsUsecase>();
  final CreatePrivateDiscussionUsecase createPrivateDiscussionUsecase =
      GetIt.instance<CreatePrivateDiscussionUsecase>();
  final UpdatePrivateDiscussionParticipationUsecase
      updatePrivateDiscussionParticipationUsecase =
      GetIt.instance<UpdatePrivateDiscussionParticipationUsecase>();
  final DecryptSymmetricKeyWithRsaPrivateKeyUsecase
      decryptSymmetricKeyWithRsaPrivateKeyUsecase =
      GetIt.instance<DecryptSymmetricKeyWithRsaPrivateKeyUsecase>();
  final DecryptMessageUsingAesUsecase decryptMessageUsingAesUsecase =
      GetIt.instance<DecryptMessageUsingAesUsecase>();

  String? userId;

  PrivateDiscussionBloc({
    required this.authBloc,
    required this.userBloc,
    required this.profileBloc,
    required this.privateMessageBloc,
    required this.webSocketService,
  }) : super(PrivateDiscussionLoaded(discussions: {})) {
    profileBlocSubscription = profileBloc.stream.listen(
      (profileState) {
        if (profileState is ProfileAuthenticated) {
          userId = profileState.profile.id;
          add(InitializePrivateDiscussionsEvent());
        }
      },
    );

    privateMessageBlocSubscription = privateMessageBloc.stream.listen(
      (privateMessageState) {
        if (privateMessageState is PrivateMessagesLoaded) {
          if (privateMessageState.lastMessageReceived != null) {
            add(
              UpdateDiscussionLastMessage(
                message: privateMessageState.lastMessageReceived!,
              ),
            );
          }
        }
      },
    );

    on<InitializePrivateDiscussionsEvent>(initialize);
    on<AddNewDiscussionEvent>(onAddNewDiscussion);
    on<UpdateDiscussionParticipationEvent>(onUpdateDiscussion);
    on<UpdateDiscussionLastMessage>(onMessageReceived);
  }

  Future<void> initialize(
    InitializePrivateDiscussionsEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state as PrivateDiscussionLoaded;
    emit(PrivateDiscussionLoading());

    final result = await getPrivateDiscussionsUsecase.call();

    final accessToken = await TokenStorage().getAccessToken();

    if (accessToken != null) {
      webSocketService.connect(accessToken);

      try {
        await webSocketService.channel.ready;
      } catch (e) {
        print("WebSocket failed to connect: $e");
        return;
      }

      webSocketService.listen(
        (message) {
          final jsonMessage = jsonDecode(message);

          final parsedMessage =
              PrivateMessageDataModel.fromJson(jsonMessage).toDomain();

          privateMessageBloc.add(
            PrivateMessageReceivedEvent(
              message: parsedMessage,
            ),
          );
        },
      );
    }

    await result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          authBloc.add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            PrivateDiscussionLoaded(
              discussions: currentState.discussions,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (discussions) async {
        Set<String> usersToGetInfoFor = <String>{};

        // Decrypt last messages of discussions to show a preview in DiscussionWidget
        for (final discussion in discussions) {
          if (discussion.lastMessage == null) {
            continue;
          }

          usersToGetInfoFor.add(discussion.lastMessage!.creator);
          usersToGetInfoFor.add(discussion.recipientId);

          final isCreator = discussion.lastMessage!.creator == userId;
          final privateKey = await PrivateMessageKeyStorage().getPrivateKey();

          String clearContent =
              "Failed to find private key. Can't decrypt this message";

          if (privateKey != null) {
            final aesKey =
                await decryptSymmetricKeyWithRsaPrivateKeyUsecase.call(
              encryptedAesKey: isCreator
                  ? discussion.lastMessage!.creatorEncryptedSessionKey
                  : discussion.lastMessage!.recipientEncryptedSessionKey,
              rsaPrivateKeyPem: privateKey,
            );
            clearContent = await decryptMessageUsingAesUsecase.call(
                encryptedContent: discussion.lastMessage!.content,
                aesKey: aesKey);
          }

          discussion.lastMessage!.content = clearContent;
        }

        // Check if we are missing some user info
        userBloc.add(
          GetUserPublicDataEvent(
            userIds: usersToGetInfoFor.toList(),
          ),
        );

        emit(
          PrivateDiscussionLoaded(
            discussions: Map.fromEntries(
              discussions.map(
                (d) => MapEntry(d.id, d),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> onAddNewDiscussion(
    AddNewDiscussionEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state as PrivateDiscussionLoaded;
    emit(PrivateDiscussionLoading());

    final result = await createPrivateDiscussionUsecase.call(
      recipientId: event.recipient,
      color: AppColorExtension.getRandomColor().toShortString(),
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
            PrivateDiscussionLoaded(
              discussions: currentState.discussions,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (newDiscussion) {
        currentState.discussions[newDiscussion.id] = newDiscussion;

        privateMessageBloc.add(
          AddNewMessageEvent(
            discussionId: newDiscussion.id,
            content: event.content,
            creatorPublicKey: event.creatorPublicKey,
            recipientPublicKey: event.recipientPublicKey,
          ),
        );

        emit(
          PrivateDiscussionLoaded(
            discussions: currentState.discussions,
          ),
        );
      },
    );
  }

  Future<void> onUpdateDiscussion(
    UpdateDiscussionParticipationEvent event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state as PrivateDiscussionLoaded;
    emit(PrivateDiscussionLoading());

    final result = await updatePrivateDiscussionParticipationUsecase.call(
      discussionId: event.discussionId,
      hasBlocked: event.hasBlocked,
      color: event.color,
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
            PrivateDiscussionLoaded(
              discussions: currentState.discussions,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        if (currentState.discussions.containsKey(event.discussionId)) {
          currentState.discussions[event.discussionId]!.color = event.color;
          currentState.discussions[event.discussionId]!.hasBlocked =
              event.hasBlocked;
        }

        emit(
          PrivateDiscussionLoaded(
            discussions: currentState.discussions,
          ),
        );
      },
    );
  }

  Future<void> onMessageReceived(
    UpdateDiscussionLastMessage event,
    Emitter<PrivateDiscussionState> emit,
  ) async {
    final currentState = state as PrivateDiscussionLoaded;
    emit(PrivateDiscussionLoading());

    if (currentState.discussions.containsKey(event.message.discussionId)) {
      currentState.discussions[event.message.discussionId]!.lastMessage =
          event.message;
    } else {
      final result = await getPrivateDiscussionsUsecase.call();

      await result.fold(
        (error) {
          if (error is ShouldLogoutError) {
            authBloc.add(
              AuthLogoutEvent(
                message: ErrorMessage(error.messageKey),
              ),
            );
          } else {
            emit(
              PrivateDiscussionLoaded(
                discussions: currentState.discussions,
                message: ErrorMessage(error.messageKey),
              ),
            );
          }
        },
        (discussions) async {
          PrivateDiscussion? newDiscussion = discussions
              .where((d) => d.id == event.message.discussionId)
              .firstOrNull;

          if (newDiscussion != null) {
            currentState.discussions[newDiscussion.id] = newDiscussion;
          }
        },
      );
    }

    emit(
      PrivateDiscussionLoaded(
        discussions: currentState.discussions,
      ),
    );
  }
}
