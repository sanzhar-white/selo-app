import 'package:selo/core/resources/data_state.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/init/data/datasources/init_datasource_interface.dart';
import 'package:selo/features/init/data/models/init_state_model.dart';
import 'package:selo/features/init/domain/repositories/init_repository.dart';

class InitRepositoryImpl implements InitRepository {

  InitRepositoryImpl(this._datasource);
  final InitDatasourceInterface _datasource;

  @override
  Future<DataState<UserModel?>> getCachedUser() {
    return _datasource.getCachedUser();
  }

  @override
  Future<DataState<Map<String, dynamic>>> getCachedSettings() {
    return _datasource.getCachedSettings();
  }

  @override
  Future<DataState<bool>> initializeServices() {
    return _datasource.initializeServices();
  }

  @override
  Future<DataState<InitStateModel>> getInitialState() {
    return _datasource.getInitialState();
  }
}
