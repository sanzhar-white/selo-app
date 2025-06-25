import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';

class ViewAdvertUseCase extends UseCase<DataState<void>, String> {

  ViewAdvertUseCase(this._homeRepository);
  final HomeRepository _homeRepository;

  @override
  Future<DataState<void>> call({String? params}) async {
    return _homeRepository.viewAdvert(params!);
  }
}
