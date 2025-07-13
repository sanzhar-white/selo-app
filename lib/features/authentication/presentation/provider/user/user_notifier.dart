import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:talker/talker.dart';
import '../providers.dart';
import 'user_state.dart';

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(this.ref) : super(const UserState()) {
    final localUser = LocalStorageService.getUser();
    if (localUser != null) {
      state = state.copyWith(user: localUser.user);
    }
  }
  final Ref ref;
  final Talker talker = di<Talker>();

  Future<bool> _executeUseCase<T>(
    Future<DataState<T>> Function() useCase, {
    UserModel? userOverride,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await useCase();
      if (result is DataSuccess && result.data != null) {
        state = state.copyWith(
          user:
              userOverride ??
              (result.data is UserModel
                  ? result.data! as UserModel
                  : result.data is AuthStatusModel
                  ? (result.data as AuthStatusModel).user
                  : null),
          isLoading: false,
        );
        return true;
      } else if (result is DataFailed) {
        state = state.copyWith(
          isLoading: false,
          error: result.error.toString(),
        );
        return false;
      }
      return false;
    } catch (e) {
      talker.error('${ErrorMessages.errorInUseCase}: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signUp(SignUpModel signUp) async {
    return _executeUseCase(
      () => ref.read(signUpUseCaseProvider).call(params: signUp),
    );
  }

  Future<bool> checkUser(String phoneNumber) async {
    return _executeUseCase(
      () => ref
          .read(checkUserUseCaseProvider)
          .call(params: PhoneNumberModel(phoneNumber: phoneNumber)),
    );
  }

  Future<bool> logIn(PhoneNumberModel phoneNumber) async {
    return _executeUseCase(
      () => ref.read(logInUseCaseProvider).call(params: phoneNumber),
    );
  }

  Future<bool> signInWithCredential(
    SignInWithCredentialModel signInWithCredential,
  ) async {
    return _executeUseCase(
      () => ref
          .read(signInWithCredentialUseCaseProvider)
          .call(params: signInWithCredential),
      userOverride: signInWithCredential.user,
    );
  }

  Future<bool> logOut() async {
    return _executeUseCase(
      () => ref.read(logOutUseCaseProvider).call(),
    );
  }

  Future<bool> anonymousLogIn() async {
    state = state.copyWith(isLoading: true);
    try {
      final localUser = LocalStorageService.getUser();
      if (localUser != null) {
        state = state.copyWith(
          user: localUser.user,
          isLoading: false,
        );
        return true;
      }

      final result = await ref.read(anonymousLogInUseCaseProvider).call();
      if (result is DataSuccess && result.data is bool) {
        final newLocalUser = LocalStorageService.getUser();
        if (newLocalUser != null) {
          state = state.copyWith(
            user: newLocalUser.user,
            isLoading: false,
          );
          return true;
        }
      }
      state = state.copyWith(
        isLoading: false,
        error: ErrorMessages.failedToGetUserData,
      );
      return false;
    } catch (e) {
      talker.error('${ErrorMessages.errorInAnonymousLogIn}: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logoutAndClearData() async {
    state = state.copyWith(isLoading: true);
    final result = await ref.read(logOutUseCaseProvider).call();
    try {
      await LocalStorageService.deleteUser();
    } catch (e) {}
    if (result is DataSuccess) {
      state = const UserState();
    } else if (result is DataFailed) {
      state = state.copyWith(isLoading: false, error: result.error.toString());
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> isAnonymous() async {
    final user = LocalStorageService.getUser();
    if (user != null) {
      return user.user.phoneNumber == '';
    }
    return false;
  }
}
