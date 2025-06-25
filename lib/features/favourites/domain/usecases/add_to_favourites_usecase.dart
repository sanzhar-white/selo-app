import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/features/favourites/domain/repositories/favourites_repository.dart';

class AddToFavouritesUseCase extends UseCase<DataState<bool>, void> {
  AddToFavouritesUseCase(this._favouritesRepository);
  final FavouritesRepository _favouritesRepository;

  @override
  Future<DataState<bool>> call({void params}) {
    return _favouritesRepository.addToFavourites(params as FavouritesModel);
  }
}
