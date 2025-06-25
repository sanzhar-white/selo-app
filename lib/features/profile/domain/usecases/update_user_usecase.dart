import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/resources/usecase.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserUseCase extends UseCase<DataState<bool>, UpdateUserModel> {

  UpdateUserUseCase(this._profileRepository);
  final ProfileRepository _profileRepository;

  @override
  Future<DataState<bool>> call({UpdateUserModel? params}) async {
    return _profileRepository.updateUser(params!);
  }
}
