import 'package:selo/core/resources/data_state.dart';
import 'package:selo/shared/models/advert_model.dart';

import '../model/favourites_model.dart';

abstract class FavouritesInterface {
  Future<DataState<List<AdvertModel>>> getFavourites(UserUidModel userUidModel);
  Future<DataState<bool>> addToFavourites(FavouritesModel favouritesModel);
  Future<DataState<bool>> removeFromFavourites(FavouritesModel favouritesModel);
  Future<DataState<bool>> toggleFavourite(FavouritesModel favouritesModel);
}
