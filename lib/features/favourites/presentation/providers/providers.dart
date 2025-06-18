import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/di/di.dart';
import 'package:selo/features/favourites/data/datasources/favourites_interface.dart';
import 'package:selo/features/favourites/data/datasources/firebase_datasource.dart';
import 'package:selo/features/favourites/data/repositories/favourites_repository_impl.dart';
import 'package:selo/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:selo/features/favourites/domain/usecases/add_to_favourites_usecase.dart';
import 'package:selo/features/favourites/domain/usecases/get_favourites_usecase.dart';
import 'package:selo/features/favourites/domain/usecases/remove_from_favourites_usecase.dart';
import 'package:selo/features/favourites/domain/usecases/toggle_favourite_usecase.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'favourites/favourites_notifier.dart';
import 'favourites/favourites_state.dart';

final firebaseDatasourceProvider = Provider<FavouritesInterface>((ref) {
  return FirebaseDatasource(di<FirebaseFirestore>(), di<Talker>());
});

final favouritesRepositoryProvider = Provider<FavouritesRepository>((ref) {
  final datasource = ref.watch(firebaseDatasourceProvider);
  return FavouritesRepositoryImpl(datasource);
});

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

final favouritesNotifierProvider =
    StateNotifierProvider<FavouritesNotifier, FavouritesState>((ref) {
      return FavouritesNotifier(ref);
    });

// Provider для отслеживания состояния лайков
final favouriteStatusProvider =
    StateNotifierProvider<FavouriteStatusNotifier, Set<String>>((ref) {
      return FavouriteStatusNotifier();
    });

class FavouriteStatusNotifier extends StateNotifier<Set<String>> {
  FavouriteStatusNotifier() : super({});

  void toggleFavourite(String advertUid) {
    final newState = Set<String>.from(state);
    if (newState.contains(advertUid)) {
      newState.remove(advertUid);
    } else {
      newState.add(advertUid);
    }
    state = newState;
  }

  void setFavourites(List<String> advertUids) {
    state = Set<String>.from(advertUids);
  }

  bool isFavourite(String advertUid) {
    return state.contains(advertUid);
  }
}
