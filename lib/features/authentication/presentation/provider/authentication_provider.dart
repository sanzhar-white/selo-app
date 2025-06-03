// lib/features/authentication/presentation/provider/authentication_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selo/features/authentication/data/datasources/firebase_datasource.dart';
import 'package:selo/features/authentication/data/datasources/user_interface.dart';
import 'package:selo/features/authentication/data/repositories/user_repository_impl.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:selo/features/authentication/data/models/user_model.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';
import 'package:selo/features/authentication/domain/entities/user_entity.dart';
import 'package:selo/features/authentication/domain/usecases/sign_up_usecase.dart';
import 'package:selo/features/authentication/domain/usecases/sign_in_with_credential_usecase.dart';
import 'package:selo/features/authentication/domain/usecases/log_out_usecase.dart';
import 'package:selo/features/authentication/domain/usecases/log_in_usecase.dart';
import 'package:selo/features/authentication/domain/usecases/check_user_usecase.dart';
import 'package:selo/features/authentication/domain/usecases/anonymous_logIn_usecase.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';

// Provider for FirebaseDatasource
final firebaseDatasourceProvider = Provider<UserInterface>((ref) {
  return FirebaseDatasource(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

// Provider for repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(firebaseDatasourceProvider);
  return UserRepositoryImpl(datasource);
});

// Provider for use case
final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return SignUpUseCase(repository);
});

final signInWithCredentialUseCaseProvider =
    Provider<SignInWithCredentialUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return SignInWithCredentialUseCase(repository);
});

final logOutUseCaseProvider = Provider<LogOutUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return LogOutUseCase(repository);
});

final logInUseCaseProvider = Provider<LogInUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return LogInUseCase(repository);
});

final checkUserUseCaseProvider = Provider<CheckUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return CheckUserUseCase(repository);
});

final anonymousLogInUseCaseProvider = Provider<AnonymousLogInUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return AnonymousLogInUseCase(repository);
});

// State class to handle loading and error states
class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const UserState({this.user, this.isLoading = false, this.error});

  UserState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Provider for state
final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((
  ref,
) {
  return UserNotifier(ref);
});

// Notifier for managing advert state
class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;

  UserNotifier(this.ref) : super(const UserState());

  Future<bool> signUp(SignUpModel signUp) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(signUpUseCaseProvider);
      final result = await useCase.call(params: signUp);

      if (result is DataSuccess && result.data is UserModel) {
        state = state.copyWith(
          user: result.data as UserModel,
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
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> checkUser(PhoneNumberModel phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(checkUserUseCaseProvider);
      final result = await useCase.call(params: phoneNumber);

      if (result is DataSuccess && result.data is UserModel) {
        state = state.copyWith(
          user: result.data as UserModel,
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
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> logIn(PhoneNumberModel phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(logInUseCaseProvider);
      final result = await useCase.call(params: phoneNumber);

      if (result is DataSuccess && result.data is UserModel) {
        state = state.copyWith(
          user: result.data as UserModel,
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
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signInWithCredential(
      SignInWithCredentialModel signInWithCredential) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(signInWithCredentialUseCaseProvider);
      final result = await useCase.call(params: signInWithCredential);

      if (result is DataSuccess && result.data is bool) {
        state = state.copyWith(isLoading: false, error: null);
        return result.data as bool;
      } else if (result is DataFailed) {
        state =
            state.copyWith(isLoading: false, error: result.error.toString());
        return false;
      }

      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> logOut() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(logOutUseCaseProvider);
      final result = await useCase.call(params: null);

      if (result is DataSuccess && result.data is bool) {
        state = state.copyWith(isLoading: false, error: null);
        return result.data as bool;
      } else if (result is DataFailed) {
        state =
            state.copyWith(isLoading: false, error: result.error.toString());
        return false;
      }

      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> anonymousLogIn() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(anonymousLogInUseCaseProvider);
      final result = await useCase.call(params: null);

      if (result is DataSuccess && result.data is bool) {
        state = state.copyWith(isLoading: false, error: null);
        return result.data as bool;
      } else if (result is DataFailed) {
        state =
            state.copyWith(isLoading: false, error: result.error.toString());
        return false;
      }

      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
