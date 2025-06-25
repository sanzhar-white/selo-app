import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';

class LogInUseCase extends UseCase<DataState<AuthStatusModel>, void> {
  LogInUseCase(this._userRepository);
  final UserRepository _userRepository;

  @override
  Future<DataState<AuthStatusModel>> call({void params}) {
    return _userRepository.logIn(params as PhoneNumberModel);
  }
}
