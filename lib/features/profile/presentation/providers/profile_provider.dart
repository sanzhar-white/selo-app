import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/features/profile/domain/repositories/profile_repository.dart';
import 'package:selo/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:selo/features/profile/data/datasources/firebase_datasource.dart';
import 'package:selo/features/profile/data/datasources/profile_interface.dart';
import 'package:selo/features/profile/domain/usecases/delete_advert_usecase.dart';
import 'package:selo/features/profile/domain/usecases/delete_user_usecase.dart';
import 'package:selo/features/profile/domain/usecases/get_my_adverts_usecase.dart';
import 'package:selo/features/profile/domain/usecases/update_user_usecase.dart';
import 'package:selo/shared/models/advert_model.dart';

final firebaseDatasourceProvider = Provider<ProfileInterface>(
  (ref) => FirebaseProfileRemoteDataSource(FirebaseFirestore.instance),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(firebaseDatasourceProvider)),
);

// Domain layer providers
final getMyAdvertsUseCaseProvider = Provider<GetMyAdvertsUseCase>(
  (ref) => GetMyAdvertsUseCase(ref.watch(profileRepositoryProvider)),
);

final deleteAdvertUseCaseProvider = Provider<DeleteAdvertUseCase>(
  (ref) => DeleteAdvertUseCase(ref.watch(profileRepositoryProvider)),
);

final deleteUserUseCaseProvider = Provider<DeleteUserUseCase>(
  (ref) => DeleteUserUseCase(ref.watch(profileRepositoryProvider)),
);

final updateUserUseCaseProvider = Provider<UpdateUserUseCase>(
  (ref) => UpdateUserUseCase(ref.watch(profileRepositoryProvider)),
);

class ProfileState {
  final List<AdvertModel>? myAdverts;
  final bool isLoading;
  final String? error;
  const ProfileState({
    this.myAdverts = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    List<AdvertModel>? myAdverts,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      myAdverts: myAdverts ?? this.myAdverts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>(
      (ref) => ProfileNotifier(ref),
    );

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref) : super(const ProfileState());

  final Ref ref;
  DateTime? _lastFetchTime;
  final Duration _cacheDuration = const Duration(minutes: 10);

  Future<void> getMyAdverts({
    bool forceRefresh = false,
    required String uid,
  }) async {
    if (!forceRefresh &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await ref
          .read(getMyAdvertsUseCaseProvider)
          .call(params: uid);
      if (result is DataSuccess<List<AdvertModel>>) {
        state = state.copyWith(myAdverts: result.data, isLoading: false);
        _lastFetchTime = DateTime.now();
      } else if (result is DataFailed) {
        state = state.copyWith(
          error: result.error?.toString() ?? 'Failed to load my adverts',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to load my adverts: $e',
        isLoading: false,
      );
    }
  }

  Future<void> deleteAdvert(String advertUid) async {
    final result = await ref
        .read(deleteAdvertUseCaseProvider)
        .call(params: advertUid);
    if (result is DataSuccess<void>) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> deleteUser(String uid) async {
    final result = await ref.read(deleteUserUseCaseProvider).call(params: uid);
    if (result is DataSuccess<void>) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateUser(UpdateUserModel updateUser) async {
    final result = await ref
        .read(updateUserUseCaseProvider)
        .call(params: updateUser);
    if (result is DataSuccess<void>) {
      state = state.copyWith(isLoading: false);
    }
  }
}
