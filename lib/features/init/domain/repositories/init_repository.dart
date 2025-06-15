import 'package:selo/core/resources/data_state.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/init/data/models/init_state_model.dart';

abstract class InitRepository {
  Future<DataState<UserModel?>> getCachedUser();
  Future<DataState<Map<String, dynamic>>> getCachedSettings();
  Future<DataState<bool>> initializeServices();
  Future<DataState<InitStateModel>> getInitialState();
}
