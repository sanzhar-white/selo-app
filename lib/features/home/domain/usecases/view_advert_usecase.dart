import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/domain/repositories/home_repository.dart';

class ViewAdvertUseCase extends UseCase<DataState<void>, String> {
  final HomeRepository _homeRepository;

  ViewAdvertUseCase(this._homeRepository);

  @override
  Future<DataState<void>> call({String? params}) async {
    return await _homeRepository.viewAdvert(params as String);
  }
}
