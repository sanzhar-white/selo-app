import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/resources/usecase.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';

class GetBannersUseCase extends UseCase<DataState<List<String>>, void> {

  GetBannersUseCase(this._homeRepository);
  final HomeRepository _homeRepository;

  @override
  Future<DataState<List<String>>> call({void params}) async {
    return _homeRepository.getBanners();
  }
}
