import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/resources/usecase.dart';
import 'package:selo/features/profile/domain/repositories/profile_repository.dart';

class DeleteUserUseCase extends UseCase<DataState<bool>, String> {

  DeleteUserUseCase(this._profileRepository);
  final ProfileRepository _profileRepository;

  @override
  Future<DataState<bool>> call({String? params}) async {
    return _profileRepository.deleteUser(params!);
  }
}
