import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/authentication/domain/entities/user_entity.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';

class SignUpUseCase extends UseCase<DataState<AuthStatusEntity>, void> {
  final UserRepository _userRepository;

  SignUpUseCase(this._userRepository);

  @override
  Future<DataState<AuthStatusEntity>> call({void params}) {
    return _userRepository.signUp(params as SignUpEntity);
  }
}
