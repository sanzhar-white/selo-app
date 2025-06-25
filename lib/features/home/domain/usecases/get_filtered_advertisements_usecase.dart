import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/resources/usecase.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';
import 'package:selo/shared/models/advert_model.dart';

class GetFilteredAdvertisementsUseCase
    extends
        UseCase<
          DataState<List<AdvertModel>>,
          ({SearchModel? searchModel, PaginationModel paginationModel})
        > {

  GetFilteredAdvertisementsUseCase(this._homeRepository);
  final HomeRepository _homeRepository;

  @override
  Future<DataState<List<AdvertModel>>> call({
    ({SearchModel? searchModel, PaginationModel paginationModel})? params,
  }) async {
    return _homeRepository.getFilteredAdvertisements(
      params?.searchModel,
      params?.paginationModel ?? const PaginationModel(),
    );
  }
}
