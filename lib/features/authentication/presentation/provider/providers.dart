import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/features/authentication/data/datasources/firebase_datasource.dart';
import 'package:selo/features/authentication/data/datasources/user_interface.dart';
import 'package:selo/features/authentication/data/repositories/user_repository_impl.dart';
import 'package:selo/features/authentication/domain/usecases/index.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:selo/shared/models/user_model.dart';
import 'user/user_notifier.dart';
import 'user/user_state.dart';

final firebaseDatasourceProvider = Provider<UserInterface>((ref) {
  return FirebaseDatasource(FirebaseFirestore.instance, FirebaseAuth.instance);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final datasource = ref.watch(firebaseDatasourceProvider);
  return UserRepositoryImpl(datasource);
});

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

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((
  ref,
) {
  return UserNotifier(ref);
});

final getUserProvider = Provider<UserModel?>((ref) {
  final userState = ref.watch(userNotifierProvider);
  return userState.user;
});
