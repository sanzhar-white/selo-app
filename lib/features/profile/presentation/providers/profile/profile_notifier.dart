import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:talker/talker.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/core/services/cache_manager.dart';

import '../providers.dart';
import 'profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier({
    required this.ref,
    required this.logger,
    required this.cacheManager,
  }) : super(const ProfileState());
  final Ref ref;
  final Talker logger;
  final CacheManager cacheManager;

  Future<void> getMyAdverts({
    required String uid,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && !cacheManager.shouldRefresh()) return;
    await _executeUseCase(
      useCase: () => ref.read(getMyAdvertsUseCaseProvider).call(params: uid),
      onSuccess: (adverts) {
        state = state.copyWith(myAdverts: adverts ?? []);
        cacheManager.updateLastFetchTime();
      },
      errorMessage: ErrorMessages.failedToLoadAdverts,
    );
  }

  Future<void> deleteAdvert(String advertUid) async {
    await _executeUseCase(
      useCase:
          () => ref.read(deleteAdvertUseCaseProvider).call(params: advertUid),
      onSuccess: (_) {
        final updatedAdverts = state.myAdverts?.toList() ?? [];
        updatedAdverts.removeWhere((advert) => advert.uid == advertUid);
        state = state.copyWith(myAdverts: updatedAdverts);
      },
      errorMessage: ErrorMessages.failedToDeleteAdvert,
    );
  }

  Future<void> deleteUser(String uid) async {
    await _executeUseCase(
      useCase: () => ref.read(deleteUserUseCaseProvider).call(params: uid),
      onSuccess: (_) => state = state.copyWith(myAdverts: [], isLoading: false),
      errorMessage: ErrorMessages.failedToDeleteUser,
    );
  }

  Future<void> updateUser(UpdateUserModel updateUser) async {
    await _executeUseCase(
      useCase:
          () => ref.read(updateUserUseCaseProvider).call(params: updateUser),
      onSuccess: (_) => state = state.copyWith(isLoading: false),
      errorMessage: ErrorMessages.failedToUpdateUser,
    );
  }

  Future<void> _executeUseCase<T>({
    required Future<DataState<T>> Function() useCase,
    required void Function(T?) onSuccess,
    required String errorMessage,
  }) async {
    await _setLoadingState();
    try {
      final result = await useCase();
      await _handleResult(result, onSuccess, errorMessage);
    } catch (e, stackTrace) {
      _handleError(errorMessage, e, stackTrace);
    }
  }

  Future<void> _setLoadingState() async {
    state = state.copyWith(isLoading: true);
  }

  Future<void> _handleResult<T>(
    DataState<T> result,
    void Function(T?) onSuccess,
    String errorMessage,
  ) async {
    if (result is DataSuccess<T>) {
      onSuccess(result.data);
      state = state.copyWith(isLoading: false);
    } else if (result is DataFailed) {
      final error = result.error?.toString() ?? ErrorMessages.unknownError;
      state = state.copyWith(isLoading: false, error: error);
      logger.error('$errorMessage: $error');
    }
  }

  void _handleError(String errorMessage, Object error, StackTrace stackTrace) {
    final formattedError = '$errorMessage: $error';
    state = state.copyWith(isLoading: false, error: formattedError);
    logger.error(formattedError, error, stackTrace);
  }
}
