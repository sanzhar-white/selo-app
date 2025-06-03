import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/authentication/domain/entities/user_entity.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';

class CheckUserUseCase extends UseCase<DataState<bool>, void> {
  final UserRepository _userRepository;

  CheckUserUseCase(this._userRepository);

  @override
  Future<DataState<bool>> call({void params}) {
    return _userRepository.checkUser(params as PhoneNumberEntity);
  }
}
