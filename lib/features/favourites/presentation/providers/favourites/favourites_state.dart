import 'package:selo/shared/models/advert_model.dart';

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
