import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';

class CheckUserUseCase extends UseCase<DataState<bool>, void> {
  CheckUserUseCase(this._userRepository);
  final UserRepository _userRepository;

  @override
  Future<DataState<bool>> call({void params}) {
    return _userRepository.checkUser(params as PhoneNumberModel);
  }
}
