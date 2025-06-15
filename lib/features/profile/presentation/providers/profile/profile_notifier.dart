import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:talker/talker.dart';
import '../providers.dart';
import 'profile_state.dart';

class CacheManager {
  static const Duration cacheDuration = Duration(minutes: 10);
  static DateTime? lastFetchTime;

  bool shouldRefresh() {
    return lastFetchTime == null ||
        DateTime.now().difference(lastFetchTime!) > cacheDuration;
  }

  void updateLastFetchTime() {
    lastFetchTime = DateTime.now();
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref ref;
  final talker = Talker();
  final cacheManager = CacheManager();

  ProfileNotifier(this.ref) : super(const ProfileState());

  Future<void> getMyAdverts({
    bool forceRefresh = false,
    required String uid,
  }) async {
    if (!forceRefresh && !cacheManager.shouldRefresh()) return;
    await _executeUseCase(
      () => ref.read(getMyAdvertsUseCaseProvider).call(params: uid),
      (adverts) {
        state = state.copyWith(myAdverts: adverts ?? []);
        cacheManager.updateLastFetchTime();
      },
      errorMessage: 'Failed to load my adverts',
    );
  }

  Future<void> deleteAdvert(String advertUid) async {
    await _executeUseCase(
      () => ref.read(deleteAdvertUseCaseProvider).call(params: advertUid),
      (_) {
        final updatedAdverts =
            state.myAdverts
                ?.where((advert) => advert.uid != advertUid)
                .toList();
        state = state.copyWith(myAdverts: updatedAdverts);
      },
      errorMessage: 'Failed to delete advert',
    );
  }

  Future<void> deleteUser(String uid) async {
    await _executeUseCase(
      () => ref.read(deleteUserUseCaseProvider).call(params: uid),
      (_) => state = state.copyWith(myAdverts: [], isLoading: false),
      errorMessage: 'Failed to delete user',
    );
  }

  Future<void> updateUser(UpdateUserModel updateUser) async {
    await _executeUseCase(
      () => ref.read(updateUserUseCaseProvider).call(params: updateUser),
      (_) => state = state.copyWith(isLoading: false),
      errorMessage: 'Failed to update user',
    );
  }

  Future<void> _executeUseCase<T>(
    Future<DataState<T>> Function() useCase,
    void Function(T?) onSuccess, {
    String? errorMessage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await useCase();
      if (result is DataSuccess<T>) {
        onSuccess(result.data);
        state = state.copyWith(isLoading: false, error: null);
      } else if (result is DataFailed) {
        state = state.copyWith(
          isLoading: false,
          error: result.error?.toString() ?? errorMessage ?? 'Unknown error',
        );
        talker.error('$errorMessage: ${result.error}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '$errorMessage: $e');
      talker.error('$errorMessage: $e');
    }
  }
}
