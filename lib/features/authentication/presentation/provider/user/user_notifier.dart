import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:talker/talker.dart';
import '../providers.dart';
import 'user_state.dart';

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;
  final talker = di<Talker>();

  UserNotifier(this.ref) : super(const UserState()) {
    final localUser = LocalStorageService.getUser();
    if (localUser != null) {
      state = state.copyWith(user: localUser.user);
    }
  }

  Future<bool> _executeUseCase<T>(
    Future<DataState<T>> Function() useCase, {
    UserModel? userOverride,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await useCase();
      if (result is DataSuccess && result.data != null) {
        state = state.copyWith(
          user:
              userOverride ??
              (result.data is UserModel ? result.data as UserModel : null),
          isLoading: false,
          error: null,
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
      talker.error('Error in use case: $e');
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
      () => ref.read(logOutUseCaseProvider).call(params: null),
    );
  }

  Future<bool> anonymousLogIn() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final localUser = LocalStorageService.getUser();
      if (localUser != null) {
        state = state.copyWith(
          user: localUser.user,
          isLoading: false,
          error: null,
        );
        return true;
      }

      final result = await ref
          .read(anonymousLogInUseCaseProvider)
          .call(params: null);
      if (result is DataSuccess && result.data is bool) {
        final newLocalUser = LocalStorageService.getUser();
        if (newLocalUser != null) {
          state = state.copyWith(
            user: newLocalUser.user,
            isLoading: false,
            error: null,
          );
          return true;
        }
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get user data',
      );
      return false;
    } catch (e) {
      talker.error('Error in anonymousLogIn: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> isAnonymous() async {
    final user = LocalStorageService.getUser();
    if (user != null) {
      return user.user.phoneNumber == null || user.user.phoneNumber == '';
    }
    return false;
  }
}
