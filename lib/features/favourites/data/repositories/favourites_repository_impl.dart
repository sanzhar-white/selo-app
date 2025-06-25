import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/favourites/data/datasources/favourites_interface.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/shared/models/advert_model.dart';
import '../../domain/repositories/favourites_repository.dart';

class FavouritesRepositoryImpl extends FavouritesRepository
    implements FavouritesInterface {
  FavouritesRepositoryImpl(this._favouritesInteface);
  final FavouritesInterface _favouritesInteface;

  @override
  Future<DataState<List<AdvertModel>>> getFavourites(
    UserUidModel userUidModel,
  ) {
    return _favouritesInteface.getFavourites(userUidModel);
  }

  @override
  Future<DataState<bool>> addToFavourites(FavouritesModel favouritesModel) {
    return _favouritesInteface.addToFavourites(favouritesModel);
  }

  @override
  Future<DataState<bool>> removeFromFavourites(
    FavouritesModel favouritesModel,
  ) {
    return _favouritesInteface.removeFromFavourites(favouritesModel);
  }

  @override
  Future<DataState<bool>> toggleFavourite(FavouritesModel favouritesModel) {
    return _favouritesInteface.toggleFavourite(favouritesModel);
  }
}
