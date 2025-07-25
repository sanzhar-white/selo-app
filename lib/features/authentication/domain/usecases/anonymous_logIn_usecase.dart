import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';

class AnonymousLogInUseCase extends UseCase<DataState<bool>, void> {

  AnonymousLogInUseCase(this._userRepository);
  final UserRepository _userRepository;

  @override
  Future<DataState<bool>> call({void params}) {
    return _userRepository.anonymousLogIn();
  }
}
