import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/init/data/models/init_state_model.dart';
import 'package:selo/features/init/domain/repositories/init_repository.dart';

class GetInitialStateUseCase
    implements UseCase<DataState<InitStateModel>, void> {
  final InitRepository _repository;

  GetInitialStateUseCase(this._repository);

  @override
  Future<DataState<InitStateModel>> call({void params}) {
    return _repository.getInitialState();
  }
}
