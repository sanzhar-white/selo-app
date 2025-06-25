import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/features/favourites/domain/repositories/favourites_repository.dart';
import 'package:selo/shared/models/advert_model.dart';

class GetFavouritesUseCase extends UseCase<DataState<List<AdvertModel>>, void> {
  GetFavouritesUseCase(this._favouritesRepository);
  final FavouritesRepository _favouritesRepository;

  @override
  Future<DataState<List<AdvertModel>>> call({void params}) {
    return _favouritesRepository.getFavourites(params as UserUidModel);
  }
}
