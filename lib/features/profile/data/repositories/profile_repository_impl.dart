import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import '../datasources/profile_interface.dart';
import '../../domain/repositories/profile_repository.dart';
import 'package:selo/shared/models/advert_model.dart';

class ProfileRepositoryImpl extends ProfileRepository
    implements ProfileInterface {
  ProfileRepositoryImpl(this._profileInteface);
  final ProfileInterface _profileInteface;

  @override
  Future<DataState<List<AdvertModel>>> getMyAdverts(String uid) {
    return _profileInteface.getMyAdverts(uid);
  }

  @override
  Future<DataState<bool>> deleteAdvert(String uid) {
    return _profileInteface.deleteAdvert(uid);
  }

  @override
  Future<DataState<bool>> deleteUser(String uid) {
    return _profileInteface.deleteUser(uid);
  }

  @override
  Future<DataState<bool>> updateUser(UpdateUserModel updateUser) {
    return _profileInteface.updateUser(updateUser);
  }
}
