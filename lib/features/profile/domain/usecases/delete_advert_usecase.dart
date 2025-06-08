import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/resources/usecase.dart';
import 'package:selo/features/profile/domain/repositories/profile_repository.dart';

class DeleteAdvertUseCase extends UseCase<DataState<bool>, String> {
  final ProfileRepository _profileRepository;

  DeleteAdvertUseCase(this._profileRepository);

  @override
  Future<DataState<bool>> call({String? params}) async {
    return await _profileRepository.deleteAdvert(params as String);
  }
}
