import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:talker/talker.dart';
import '../providers.dart';
import 'favourites_state.dart';

class CacheManager {
  static const Duration cacheDuration = Duration(minutes: 3);
  static DateTime? lastFetchTime;

  bool shouldRefresh() {
    return lastFetchTime == null ||
        DateTime.now().difference(lastFetchTime!) > cacheDuration;
  }

  void updateLastFetchTime() {
    lastFetchTime = DateTime.now();
  }
}

class FavouritesNotifier extends StateNotifier<FavouritesState> {
  final Ref ref;
  final talker = Talker();
  final cacheManager = CacheManager();
  final Map<String, bool> _loadingAdverts = {};

  FavouritesNotifier(this.ref) : super(const FavouritesState());

  bool isAdvertLoading(String advertUid) => _loadingAdverts[advertUid] ?? false;

  void _startLoadingAdvert(String advertUid) {
    _loadingAdverts[advertUid] = true;
  }

  void _stopLoadingAdvert(String advertUid) {
    _loadingAdverts.remove(advertUid);
  }

  Future<bool> getFavourites(UserUidModel userUid, {bool force = false}) async {
    if (!force && !cacheManager.shouldRefresh()) return true;
    return _executeUseCase(
      () => ref.read(getFavouritesUseCaseProvider).call(params: userUid),
      onSuccess: (List<AdvertModel>? favourites) {
        state = state.copyWith(favouritesModel: favourites);
        cacheManager.updateLastFetchTime();
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
    );
  }

  Future<bool> _handleAdvertAction({
    required String advertUid,
    required String userUid,
    required Future<DataState<bool>> Function() action,
    required String errorMessage,
  }) async {
    if (isAdvertLoading(advertUid)) return false;
    _startLoadingAdvert(advertUid);
    state = state.copyWith(error: null);
    try {
      final result = await action();
      if (result is DataSuccess && result.data == true) {
        return await getFavourites(UserUidModel(uid: userUid), force: true);
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
    if (updateLoading) state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await useCase();
      if (result is DataSuccess<T>) {
        onSuccess(result.data);
        if (updateLoading)
          state = state.copyWith(isLoading: false, error: null);
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
