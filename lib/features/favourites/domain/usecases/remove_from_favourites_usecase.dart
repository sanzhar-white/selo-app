import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/features/favourites/domain/repositories/favourites_repository.dart';

class RemoveFromFavouritesUseCase extends UseCase<DataState<bool>, void> {
  final FavouritesRepository _favouritesRepository;

  RemoveFromFavouritesUseCase(this._favouritesRepository);

  @override
  Future<DataState<bool>> call({void params}) {
    return _favouritesRepository.removeFromFavourites(
      params as FavouritesModel,
    );
  }
}
