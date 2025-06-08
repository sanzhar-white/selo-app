import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:selo/features/home/data/models/home_model.dart';

class GetAllAdvertisementsUseCase
    extends UseCase<DataState<List<AdvertModel>>, void> {
  final HomeRepository _homeRepository;

  GetAllAdvertisementsUseCase(this._homeRepository);

  @override
  Future<DataState<List<AdvertModel>>> call({void params}) async {
    return await _homeRepository.getAllAdvertisements(
      params as PaginationModel,
    );
  }
}
