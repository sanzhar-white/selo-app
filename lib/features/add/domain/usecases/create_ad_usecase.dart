import 'package:selo/core/resources/usecase.dart';
import 'package:selo/features/add/domain/repositories/advert_repository.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/domain/entities/advert_entity.dart';

class CreateAdUseCase extends UseCase<DataState<AdvertEntity>, void> {
  final AdvertRepository _advertRepository;

  CreateAdUseCase(this._advertRepository);

  @override
  Future<DataState<AdvertEntity>> call({void params}) {
    return _advertRepository.createAd(params as AdvertEntity);
  }
}
