import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';

class SignUpUseCase extends UseCase<DataState<AuthStatusModel>, void> {
  SignUpUseCase(this._userRepository);
  final UserRepository _userRepository;

  @override
  Future<DataState<AuthStatusModel>> call({void params}) {
    return _userRepository.signUp(params as SignUpModel);
  }
}
