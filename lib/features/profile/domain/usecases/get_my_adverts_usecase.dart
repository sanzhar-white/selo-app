import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/resources/usecase.dart';
import 'package:selo/features/profile/domain/repositories/profile_repository.dart';
import 'package:selo/shared/models/advert_model.dart';

class GetMyAdvertsUseCase
    extends UseCase<DataState<List<AdvertModel>>, String> {

  GetMyAdvertsUseCase(this._profileRepository);
  final ProfileRepository _profileRepository;

  @override
  Future<DataState<List<AdvertModel>>> call({String? params}) async {
    return _profileRepository.getMyAdverts(params!);
  }
}
