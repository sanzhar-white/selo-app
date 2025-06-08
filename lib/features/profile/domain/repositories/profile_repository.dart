import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/shared/models/advert_model.dart';

abstract class ProfileRepository {
  Future<DataState<List<AdvertModel>>> getMyAdverts(String uid);

  Future<DataState<bool>> deleteAdvert(String uid);

  Future<DataState<bool>> deleteUser(String uid);

  Future<DataState<bool>> updateUser(UpdateUserModel updateUser);
}
