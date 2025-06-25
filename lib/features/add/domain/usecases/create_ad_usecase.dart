import 'package:selo/core/resources/usecase.dart';
import 'package:selo/features/add/domain/repositories/advert_repository.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/shared/models/advert_model.dart';

class CreateAdUseCase extends UseCase<DataState<AdvertModel>, void> {
  CreateAdUseCase(this._advertRepository);
  final AdvertRepository _advertRepository;

  @override
  Future<DataState<AdvertModel>> call({void params}) {
    return _advertRepository.createAd(params as AdvertModel);
  }
}
