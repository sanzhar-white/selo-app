import 'package:selo/core/resources/usecase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/authentication/data/models/user_model.dart';
import 'package:selo/features/authentication/domain/repositories/user_repository.dart';

class SignInWithCredentialUseCase extends UseCase<DataState<bool>, void> {
  final UserRepository _userRepository;

  SignInWithCredentialUseCase(this._userRepository);

  @override
  Future<DataState<bool>> call({void params}) {
    return _userRepository.signInWithCredential(
      params as SignInWithCredentialModel,
    );
  }
}
