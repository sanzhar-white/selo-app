import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/features/favourites/data/datasources/favourites_interface.dart';
import 'package:selo/features/favourites/data/datasources/firebase_datasource.dart';
import 'package:selo/features/favourites/data/repositories/favourites_repository_impl.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/favourites/domain/usecases/add_to_favourites_usecase.dart';
import 'package:selo/features/favourites/domain/usecases/get_favourites_usecase.dart';
import 'package:selo/features/favourites/domain/usecases/remove_from_favourites_usecase.dart';
import 'package:selo/features/favourites/domain/usecases/toggle_favourite_usecase.dart';
import 'package:selo/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/shared/models/advert_model.dart';

// Data layer providers
final firebaseDatasourceProvider = Provider<FavouritesInteface>((ref) {
  return FirebaseDatasource(FirebaseFirestore.instance);
});

final favouritesRepositoryProvider = Provider<FavouritesRepository>((ref) {
  final datasource = ref.watch(firebaseDatasourceProvider);
  return FavouritesRepositoryImpl(datasource);
});

// Domain layer providers
final addToFavouritesUseCaseProvider = Provider<AddToFavouritesUseCase>((ref) {
  final repository = ref.watch(favouritesRepositoryProvider);
  return AddToFavouritesUseCase(repository);
});

final removeFromFavouritesUseCaseProvider =
    Provider<RemoveFromFavouritesUseCase>((ref) {
      final repository = ref.watch(favouritesRepositoryProvider);
      return RemoveFromFavouritesUseCase(repository);
    });

final getFavouritesUseCaseProvider = Provider<GetFavouritesUseCase>((ref) {
  final repository = ref.watch(favouritesRepositoryProvider);
  return GetFavouritesUseCase(repository);
});

final toggleFavouriteUseCaseProvider = Provider<ToggleFavouriteUseCase>((ref) {
  final repository = ref.watch(favouritesRepositoryProvider);
  return ToggleFavouriteUseCase(repository);
});

// Presentation layer
class FavouritesState {
  final List<AdvertModel>? favouritesModel;
  final bool isLoading;
  final String? error;

  const FavouritesState({
    this.favouritesModel,
    this.isLoading = false,
    this.error,
  });

  FavouritesState copyWith({
    List<AdvertModel>? favouritesModel,
    bool? isLoading,
    String? error,
  }) {
    return FavouritesState(
      favouritesModel: favouritesModel ?? this.favouritesModel,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final favouritesNotifierProvider =
    StateNotifierProvider<FavouritesNotifier, FavouritesState>((ref) {
      return FavouritesNotifier(ref);
    });

class FavouritesNotifier extends StateNotifier<FavouritesState> {
  final Ref ref;
  final Map<String, bool> _loadingAdverts = {};
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 3);

  FavouritesNotifier(this.ref) : super(const FavouritesState());

  bool isAdvertLoading(String advertUid) => _loadingAdverts[advertUid] ?? false;

  /// --- Публичные методы ---
  Future<bool> getFavourites(UserUidModel userUid, {bool force = false}) async {
    if (!force &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return true; // Используем кэш
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getFavouritesUseCaseProvider);
      final result = await useCase.call(params: userUid);

      if (result is DataSuccess<List<AdvertModel>>) {
        state = state.copyWith(favouritesModel: result.data);
        _lastFetchTime = DateTime.now();
        return true;
      } else if (result is DataFailed) {
        state = state.copyWith(error: result.error.toString());
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to load favourites: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
    return false;
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

  /// --- Приватный универсальный обработчик ---
  Future<bool> _handleAdvertAction({
    required String advertUid,
    required String userUid,
    required Future<DataState<bool>> Function() action,
    required String errorMessage,
  }) async {
    if (isAdvertLoading(advertUid)) return false;

    _loadingAdverts[advertUid] = true;
    state = state.copyWith(error: null);

    try {
      final result = await action();
      if (result is DataSuccess && result.data == true) {
        return await getFavourites(UserUidModel(uid: userUid), force: true);
      } else if (result is DataFailed) {
        state = state.copyWith(error: result.error.toString());
      }
    } catch (e) {
      state = state.copyWith(error: '$errorMessage: $e');
    } finally {
      _loadingAdverts.remove(advertUid);
    }

    return false;
  }
}
