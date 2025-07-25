import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';

class LogOutUseCase extends UseCase<DataState<bool>, void> {

  LogOutUseCase(this._userRepository);
  final UserRepository _userRepository;

  @override
  Future<DataState<bool>> call({void params}) {
    return _userRepository.logOut();
  }
}
