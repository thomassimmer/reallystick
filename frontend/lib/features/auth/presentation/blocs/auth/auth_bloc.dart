import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:bloc/bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:reallystick/core/messages/message.dart';
import 'package:reallystick/core/utils/recovery_code_generator.dart';
import 'package:reallystick/features/auth/data/storage/private_message_key_storage.dart';
import 'package:reallystick/features/auth/data/storage/token_storage.dart';
import 'package:reallystick/features/auth/domain/errors/domain_error.dart';
import 'package:reallystick/features/auth/domain/usecases/check_if_account_has_two_factor_authentication_enabled_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/decrypt_key_using_derivated_key_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/derive_key_from_password_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/encrypt_key_using_derivated_key_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/generate_rsa_keys_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/generate_two_factor_authentication_config_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/login_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/logout_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/recover_account_with_two_factor_authentication_and_one_time_password_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/recover_account_with_two_factor_authentication_and_password_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/recover_account_without_two_factor_authentication_enabled_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/save_keys_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/save_recovery_code_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/signup_usecase.dart';
import 'package:reallystick/features/auth/domain/usecases/validate_one_time_password_use_case.dart';
import 'package:reallystick/features/auth/domain/usecases/verify_one_time_password_use_case.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_events.dart';
import 'package:reallystick/features/auth/presentation/blocs/auth/auth_states.dart';
import 'package:reallystick/features/private_messages/domain/usecases/decrypt_message_using_aes_usecase.dart';
import 'package:reallystick/features/private_messages/domain/usecases/encrypt_message_using_aes_usecase.dart';
import 'package:universal_io/io.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase = GetIt.instance<LoginUseCase>();
  final LogoutUseCase logoutUseCase = GetIt.instance<LogoutUseCase>();
  final SignupUseCase signupUseCase = GetIt.instance<SignupUseCase>();
  final GenerateTwoFactorAuthenticationConfigUseCase
      generateTwoFactorAuthenticationConfigUseCase =
      GetIt.instance<GenerateTwoFactorAuthenticationConfigUseCase>();
  final VerifyOneTimePasswordUseCase verifyOneTimePasswordUseCase =
      GetIt.instance<VerifyOneTimePasswordUseCase>();
  final ValidateOneTimePasswordUseCase validateOneTimePasswordUseCase =
      GetIt.instance<ValidateOneTimePasswordUseCase>();
  final CheckIfAccountHasTwoFactorAuthenticationEnabledUseCase
      checkIfAccountHasTwoFactorAuthenticationEnabledUseCase =
      GetIt.instance<CheckIfAccountHasTwoFactorAuthenticationEnabledUseCase>();
  final RecoverAccountWithTwoFactorAuthenticationAndPasswordUseCase
      recoverAccountWithTwoFactorAuthenticationAndPasswordUseCase =
      GetIt.instance<
          RecoverAccountWithTwoFactorAuthenticationAndPasswordUseCase>();
  final RecoverAccountWithTwoFactorAuthenticationAndOneTimePasswordUseCase
      recoverAccountWithTwoFactorAuthenticationAndOneTimePasswordUseCase =
      GetIt.instance<
          RecoverAccountWithTwoFactorAuthenticationAndOneTimePasswordUseCase>();
  final RecoverAccountWithoutTwoFactorAuthenticationEnabledUseCase
      recoverAccountWithoutTwoFactorAuthenticationEnabledUseCase =
      GetIt.instance<
          RecoverAccountWithoutTwoFactorAuthenticationEnabledUseCase>();
  final SaveRecoveryCodeUsecase saveRecoveryCodeUsecase =
      GetIt.instance<SaveRecoveryCodeUsecase>();
  final SaveKeysUsecase saveKeysUsecase = GetIt.instance<SaveKeysUsecase>();
  final DecryptKeyUsingDerivatedKeyUsecase decryptKeyUsingDerivatedKeyUsecase =
      GetIt.instance<DecryptKeyUsingDerivatedKeyUsecase>();
  final DecryptMessageUsingAesUsecase decryptMessageUsingAesUsecase =
      GetIt.instance<DecryptMessageUsingAesUsecase>();
  final DeriveKeyFromPasswordUsecase deriveKeyFromPasswordUsecase =
      GetIt.instance<DeriveKeyFromPasswordUsecase>();
  final EncryptKeyUsingDerivatedKeyUsecase encryptKeyUsingDerivatedKeyUsecase =
      GetIt.instance<EncryptKeyUsingDerivatedKeyUsecase>();
  final EncryptMessageUsingAesUsecase encryptMessageUsingAesUsecase =
      GetIt.instance<EncryptMessageUsingAesUsecase>();
  final GenerateRSAKeysUsecase generateRSAKeysUsecase =
      GetIt.instance<GenerateRSAKeysUsecase>();

  AuthBloc() : super(AuthLoadingState()) {
    on<AuthInitializeEvent>(_initialize);
    on<AuthSignupEvent>(_signup);
    on<AuthGenerateTwoFactorAuthenticationConfigEvent>(
        _generateTwoFactorAuthenticationConfig);
    on<AuthVerifyOneTimePasswordEvent>(_verifyOneTimePassword);
    on<AuthLoginEvent>(_login);
    on<AuthValidateOneTimePasswordEvent>(_validateOneTimePassword);
    on<AuthLogoutEvent>(_logout);
    on<AuthRecoverAccountForUsernameEvent>(_recoverAccountForUsername);
    on<AuthCheckIfAccountHasTwoFactorAuthenticationEnabledEvent>(
        _checkIfAccountHasTwoFactorAuthenticationEnabled);
    on<AuthRecoverAccountWithTwoFactorAuthenticationAndPasswordEvent>(
        _recoverAccountWithTwoFactorAuthenticationAndPassword);
    on<AuthRecoverAccountWithTwoFactorAuthenticationAndOneTimePasswordEvent>(
        _recoverAccountWithTwoFactorAuthenticationAndOneTimePassword);
    on<AuthRecoverAccountWithoutTwoFactorAuthenticationEnabledEvent>(
        _recoverAccountWithoutTwoFactorAuthenticationEnabled);
  }

  // Function to check initial authentication state
  Future<void> _initialize(
      AuthInitializeEvent event, Emitter<AuthState> emit) async {
    final result = await TokenStorage().getAccessToken();

    if (result == null) {
      emit(AuthUnauthenticatedState());
    } else {
      emit(
        AuthAuthenticatedAfterLoginState(hasValidatedOtp: false),
      );
    }
  }

  Future<void> saveOrGenerateKeys({
    required String? privateKeyEncrypted,
    required String passwordOrRecoveryCode,
    required String? salt,
    required String? publicKey,
  }) async {
    if (privateKeyEncrypted == null) {
      final keyPair = generateRSAKeysUsecase.call();

      final publicKey = CryptoUtils.encodeRSAPublicKeyToPem(
          keyPair.publicKey as RSAPublicKey);
      final privateKey = CryptoUtils.encodeRSAPrivateKeyToPem(
          keyPair.privateKey as RSAPrivateKey);

      final derivatedKeyResult = await deriveKeyFromPasswordUsecase.call(
        password: passwordOrRecoveryCode,
        salt: null,
      );

      final privateKeyEncrypted = encryptKeyUsingDerivatedKeyUsecase.call(
        privateKey: privateKey,
        derivedKey: derivatedKeyResult.derivedKey,
      );

      await saveKeysUsecase.call(
        publicKey: publicKey,
        privateKey: privateKey,
        privateKeyEncrypted: privateKeyEncrypted,
        saltUsedToDeriveKeyFromPassword: derivatedKeyResult.salt,
      );
    } else {
      final derivatedKeyResult = await deriveKeyFromPasswordUsecase.call(
        password: passwordOrRecoveryCode,
        salt: base64Decode(salt!).toList(),
      );

      final privateKey = decryptKeyUsingDerivatedKeyUsecase.call(
        encryptedData: privateKeyEncrypted,
        derivedKey: derivatedKeyResult.derivedKey,
      );

      await PrivateMessageKeyStorage().saveKeys(
        publicKey!,
        CryptoUtils.encodeRSAPrivateKeyToPem(privateKey),
      );
    }
  }

  void _signup(AuthSignupEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final keyPair = generateRSAKeysUsecase.call();

    final publicKey =
        CryptoUtils.encodeRSAPublicKeyToPem(keyPair.publicKey as RSAPublicKey);
    final privateKey = CryptoUtils.encodeRSAPrivateKeyToPem(
        keyPair.privateKey as RSAPrivateKey);

    final derivatedKeyResult = await deriveKeyFromPasswordUsecase.call(
      password: event.password,
      salt: null,
    );

    final privateKeyEncrypted = encryptKeyUsingDerivatedKeyUsecase.call(
      privateKey: privateKey,
      derivedKey: derivatedKeyResult.derivedKey,
    );

    final result = await signupUseCase.call(
      username: event.username,
      password: event.password,
      locale:
          Platform.localeName, // We use the device locale by default on signup
      theme: event.theme,
      publicKey: publicKey,
      privateKey: privateKey,
      privateKeyEncrypted: privateKeyEncrypted,
      saltUsedToDeriveKeyFromPassword: derivatedKeyResult.salt,
    );

    await result.fold(
      (error) {
        emit(
          AuthUnauthenticatedState(
            message: ErrorMessage(error.messageKey),
          ),
        );
      },
      (userToken) async {
        String recoveryCode = RecoveryCodeGenerator.generate();
        String privateKey =
            await PrivateMessageKeyStorage().getPrivateKey() ?? "";

        final derivatedKey = await deriveKeyFromPasswordUsecase.call(
          password: recoveryCode,
          salt: null,
        );

        String privateKeyEncrypted = encryptKeyUsingDerivatedKeyUsecase.call(
          privateKey: privateKey,
          derivedKey: derivatedKey.derivedKey,
        );

        await saveRecoveryCodeUsecase.call(
          recoveryCode: recoveryCode,
          privateKeyEncrypted: privateKeyEncrypted,
          saltUsedToDeriveKeyFromRecoveryCode: derivatedKey.salt,
        );

        emit(
          AuthAuthenticatedAfterRegistrationState(
            recoveryCode: recoveryCode,
            hasVerifiedOtp: false,
          ),
        );
      },
    );
  }

  void _generateTwoFactorAuthenticationConfig(
      AuthGenerateTwoFactorAuthenticationConfigEvent event,
      Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final result = await generateTwoFactorAuthenticationConfigUseCase.call();

    result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            AuthUnauthenticatedState(
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (twoFactorAuthenticationConfig) => {
        emit(
          AuthVerifyOneTimePasswordState(
            otpAuthUrl: twoFactorAuthenticationConfig.otpAuthUrl,
            otpBase32: twoFactorAuthenticationConfig.otpBase32,
          ),
        )
      },
    );
  }

  void _verifyOneTimePassword(
      AuthVerifyOneTimePasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final result = await verifyOneTimePasswordUseCase.call(event.code);

    result.fold(
      (error) {
        if (error is ShouldLogoutError) {
          add(
            AuthLogoutEvent(
              message: ErrorMessage(error.messageKey),
            ),
          );
        } else {
          emit(
            AuthVerifyOneTimePasswordState(
              otpAuthUrl: event.otpAuthUrl,
              otpBase32: event.otpBase32,
              message: ErrorMessage(error.messageKey),
            ),
          );
        }
      },
      (_) {
        emit(
          AuthAuthenticatedAfterRegistrationState(
            hasVerifiedOtp: true,
            message: SuccessMessage("validationCodeCorrect"),
          ),
        );
      },
    );
  }

  Future<void> _login(AuthLoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final result = await loginUseCase.call(
      event.username,
      event.password,
    );

    await result.fold(
      (error) {
        emit(
          AuthUnauthenticatedState(
            message: ErrorMessage(error.messageKey),
          ),
        );
      },
      (userTokenOrUserId) async {
        await userTokenOrUserId.fold(
          (userToken) async {
            await saveOrGenerateKeys(
              privateKeyEncrypted: userToken.privateKeyEncrypted,
              passwordOrRecoveryCode: event.password,
              salt: userToken.saltUsedToDeriveKey,
              publicKey: userToken.publicKey,
            );

            emit(
              AuthAuthenticatedAfterLoginState(
                hasValidatedOtp: false,
                message: SuccessMessage("loginSuccessful"),
              ),
            );
          },
          (userDataBeforeOtpVerified) async {
            emit(
              AuthValidateOneTimePasswordState(
                userId: userDataBeforeOtpVerified.userId,
                password: event.password,
              ),
            );
          },
        );
      },
    );
  }

  void _validateOneTimePassword(
      AuthValidateOneTimePasswordEvent event, Emitter<AuthState> emit) async {
    final currentState = state as AuthValidateOneTimePasswordState;
    emit(AuthLoadingState());

    final result = await validateOneTimePasswordUseCase.call(
      event.userId,
      event.code,
    );

    await result.fold(
      (error) {
        emit(
          AuthValidateOneTimePasswordState(
            message: ErrorMessage(error.messageKey),
            password: currentState.password,
            userId: event.userId,
          ),
        );
      },
      (userToken) async {
        await saveOrGenerateKeys(
          privateKeyEncrypted: userToken.privateKeyEncrypted,
          passwordOrRecoveryCode: currentState.password,
          salt: userToken.saltUsedToDeriveKey,
          publicKey: userToken.publicKey,
        );

        emit(
          AuthAuthenticatedAfterLoginState(
            hasValidatedOtp: true,
            message: SuccessMessage("loginSuccessful"),
          ),
        );
      },
    );
  }

  void _logout(AuthLogoutEvent event, Emitter<AuthState> emit) async {
    final result = await logoutUseCase.call();

    await result.fold(
      (error) {
        emit(
          AuthUnauthenticatedState(
            message: ErrorMessage(error.messageKey),
          ),
        );
      },
      (_) async {
        await TokenStorage().deleteTokens();

        if (event.message == null) {
          emit(
            AuthUnauthenticatedState(
              message: SuccessMessage('logoutSuccessful'),
            ),
          );
        } else {
          emit(
            AuthUnauthenticatedState(message: event.message),
          );
        }
      },
    );
  }

  void _recoverAccountForUsername(
      AuthRecoverAccountForUsernameEvent event, Emitter<AuthState> emit) async {
    emit(
      AuthRecoverAccountUsernameStepState(
        username: event.username,
        passwordForgotten: event.passwordForgotten,
      ),
    );
  }

  void _checkIfAccountHasTwoFactorAuthenticationEnabled(
      AuthCheckIfAccountHasTwoFactorAuthenticationEnabledEvent event,
      Emitter<AuthState> emit) async {
    final currentState = state;
    emit(AuthLoadingState());

    final result = await checkIfAccountHasTwoFactorAuthenticationEnabledUseCase
        .call(event.username);

    result.fold(
      (error) => emit(
        AuthRecoverAccountUsernameStepState(
          username: event.username,
          passwordForgotten: event.passwordForgotten,
          message: ErrorMessage(error.messageKey),
        ),
      ),
      (isTwoFactorAuthenticationEnabled) async {
        if (currentState is AuthRecoverAccountUsernameStepState) {
          if (isTwoFactorAuthenticationEnabled) {
            if (currentState.passwordForgotten) {
              emit(
                AuthRecoverAccountWithTwoFactorAuthenticationEnabledAndOneTimePasswordState(
                  username: event.username,
                  passwordForgotten: currentState.passwordForgotten,
                ),
              );
            } else {
              emit(
                AuthRecoverAccountWithTwoFactorAuthenticationEnabledAndPasswordState(
                  username: event.username,
                  passwordForgotten: currentState.passwordForgotten,
                ),
              );
            }
          } else {
            emit(
              AuthRecoverAccountWithoutTwoFactorAuthenticationEnabledState(
                username: event.username,
                passwordForgotten: currentState.passwordForgotten,
              ),
            );
          }
        }
      },
    );
  }

  void _recoverAccountWithTwoFactorAuthenticationAndPassword(
      AuthRecoverAccountWithTwoFactorAuthenticationAndPasswordEvent event,
      Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final result =
        await recoverAccountWithTwoFactorAuthenticationAndPasswordUseCase.call(
      username: event.username,
      password: event.password,
      recoveryCode: event.recoveryCode,
    );

    result.fold(
      (error) => emit(
        AuthUnauthenticatedState(
          message: ErrorMessage(error.messageKey),
        ),
      ),
      (userToken) async {
        await saveOrGenerateKeys(
          privateKeyEncrypted: userToken.privateKeyEncrypted,
          passwordOrRecoveryCode: event.password,
          salt: userToken.saltUsedToDeriveKey,
          publicKey: userToken.publicKey,
        );

        emit(
          AuthAuthenticatedAfterLoginState(
            hasValidatedOtp: true,
            message: SuccessMessage("loginSuccessful"),
          ),
        );
      },
    );
  }

  void _recoverAccountWithTwoFactorAuthenticationAndOneTimePassword(
      AuthRecoverAccountWithTwoFactorAuthenticationAndOneTimePasswordEvent
          event,
      Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final result =
        await recoverAccountWithTwoFactorAuthenticationAndOneTimePasswordUseCase
            .call(
      username: event.username,
      code: event.code,
      recoveryCode: event.recoveryCode,
    );

    result.fold(
      (error) => emit(
        AuthUnauthenticatedState(
          message: ErrorMessage(error.messageKey),
        ),
      ),
      (userToken) async {
        await saveOrGenerateKeys(
          privateKeyEncrypted: userToken.privateKeyEncrypted,
          passwordOrRecoveryCode: event.recoveryCode,
          salt: userToken.saltUsedToDeriveKey,
          publicKey: userToken.publicKey,
        );

        emit(
          AuthAuthenticatedAfterLoginState(
            hasValidatedOtp: true,
            message: SuccessMessage("loginSuccessful"),
          ),
        );
      },
    );
  }

  void _recoverAccountWithoutTwoFactorAuthenticationEnabled(
      AuthRecoverAccountWithoutTwoFactorAuthenticationEnabledEvent event,
      Emitter<AuthState> emit) async {
    emit(AuthLoadingState());

    final result =
        await recoverAccountWithoutTwoFactorAuthenticationEnabledUseCase.call(
      username: event.username,
      recoveryCode: event.recoveryCode,
    );

    result.fold(
      (error) => emit(
        AuthUnauthenticatedState(
          message: ErrorMessage(error.messageKey),
        ),
      ),
      (userToken) async {
        await saveOrGenerateKeys(
          privateKeyEncrypted: userToken.privateKeyEncrypted,
          passwordOrRecoveryCode: event.recoveryCode,
          salt: userToken.saltUsedToDeriveKey,
          publicKey: userToken.publicKey,
        );

        emit(
          AuthAuthenticatedAfterLoginState(
            hasValidatedOtp: true,
            message: SuccessMessage("loginSuccessful"),
          ),
        );
      },
    );
  }
}
