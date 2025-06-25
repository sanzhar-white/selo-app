import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:talker/talker.dart';
import '../providers.dart';
import 'favourites_state.dart';

class FavouritesNotifier extends StateNotifier<FavouritesState> {
  FavouritesNotifier(this.ref) : super(const FavouritesState());
  final Ref ref;
  final Talker talker = di<Talker>();
  final Map<String, bool> _loadingAdverts = {};

  bool isAdvertLoading(String advertUid) => _loadingAdverts[advertUid] ?? false;

  void _startLoadingAdvert(String advertUid) {
    _loadingAdverts[advertUid] = true;
  }

  void _stopLoadingAdvert(String advertUid) {
    _loadingAdverts.remove(advertUid);
  }

  Future<bool> getFavourites(UserUidModel userUid) async {
    return _executeUseCase(
      () => ref.read(getFavouritesUseCaseProvider).call(params: userUid),
      onSuccess: (favourites) {
        state = state.copyWith(favouritesModel: favourites);
        if (favourites != null) {
          ref
              .read(favouriteStatusProvider.notifier)
              .setFavourites(favourites.map((ad) => ad.uid).toList());
        }
      },
      errorMessage: 'Failed to load favourites',
    );
  }

  Future<bool> addToFavourites({
    required String userUid,
    required String advertUid,
  }) async {
    return _handleAdvertAction(
      advertUid: advertUid,
      userUid: userUid,
      action:
          () => ref
              .read(addToFavouritesUseCaseProvider)
              .call(
                params: FavouritesModel(
                  userUid: UserUidModel(uid: userUid),
                  advertUid: AdvertUidModel(uid: advertUid),
                ),
              ),
      errorMessage: 'Failed to add to favourites',
      onSuccess: () {
        ref.read(favouriteStatusProvider.notifier).toggleFavourite(advertUid);
      },
    );
  }

  Future<bool> removeFromFavourites({
    required String userUid,
    required String advertUid,
  }) async {
    return _handleAdvertAction(
      advertUid: advertUid,
      userUid: userUid,
      action:
          () => ref
              .read(removeFromFavouritesUseCaseProvider)
              .call(
                params: FavouritesModel(
                  userUid: UserUidModel(uid: userUid),
                  advertUid: AdvertUidModel(uid: advertUid),
                ),
              ),
      errorMessage: 'Failed to remove from favourites',
      onSuccess: () {
        ref.read(favouriteStatusProvider.notifier).toggleFavourite(advertUid);
      },
    );
  }

  Future<bool> toggleFavourite({
    required String userUid,
    required String advertUid,
  }) async {
    return _handleAdvertAction(
      advertUid: advertUid,
      userUid: userUid,
      action:
          () => ref
              .read(toggleFavouriteUseCaseProvider)
              .call(
                params: FavouritesModel(
                  userUid: UserUidModel(uid: userUid),
                  advertUid: AdvertUidModel(uid: advertUid),
                ),
              ),
      errorMessage: 'Failed to toggle favourite',
      onSuccess: () {
        ref.read(favouriteStatusProvider.notifier).toggleFavourite(advertUid);
      },
    );
  }

  Future<bool> _handleAdvertAction({
    required String advertUid,
    required String userUid,
    required Future<DataState<bool>> Function() action,
    required String errorMessage,
    required VoidCallback onSuccess,
  }) async {
    if (isAdvertLoading(advertUid)) return false;
    _startLoadingAdvert(advertUid);
    state = state.copyWith();
    try {
      final result = await action();
      if (result is DataSuccess && result.data == true) {
        onSuccess();
        return await getFavourites(UserUidModel(uid: userUid));
      } else if (result is DataFailed) {
        state = state.copyWith(error: result.error.toString());
        talker.error('$errorMessage: ${result.error}');
      }
    } catch (e) {
      state = state.copyWith(error: '$errorMessage: $e');
      talker.error('$errorMessage: $e');
    } finally {
      _stopLoadingAdvert(advertUid);
    }
    return false;
  }

  Future<bool> _executeUseCase<T>(
    Future<DataState<T>> Function() useCase, {
    required void Function(T?) onSuccess,
    String? errorMessage,
    bool updateLoading = true,
  }) async {
    if (updateLoading) state = state.copyWith(isLoading: true);
    try {
      final result = await useCase();
      if (result is DataSuccess<T>) {
        onSuccess(result.data);
        if (updateLoading) {
          state = state.copyWith(isLoading: false);
        }
        return true;
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
    return false;
  }
}
