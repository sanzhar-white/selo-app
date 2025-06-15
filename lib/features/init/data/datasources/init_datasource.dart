import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/shared/models/local_user_model.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/init/data/datasources/init_datasource_interface.dart';
import 'package:selo/features/init/data/models/init_state_model.dart';

class InitDatasource implements InitDatasourceInterface {
  @override
  Future<DataState<UserModel?>> getCachedUser() async {
    try {
      final LocalUserModel? localUser = LocalStorageService.getUser();
      if (localUser == null) {
        return const DataSuccess(null);
      }

      // Convert LocalUserModel to UserModel
      final userModel = UserModel(
        uid: localUser.user.uid,
        phoneNumber: localUser.user.phoneNumber,
        name: localUser.user.name,
        lastName: localUser.user.lastName,
        likes: localUser.user.likes,
        region: localUser.user.region,
        district: localUser.user.district,
        profileImage: localUser.user.profileImage,
        createdAt: localUser.user.createdAt,
        updatedAt: localUser.user.updatedAt,
      );

      return DataSuccess(userModel);
    } catch (e, st) {
      return DataFailed(Exception(e.toString()), st);
    }
  }

  @override
  Future<DataState<Map<String, dynamic>>> getCachedSettings() async {
    try {
      // Implement getting cached settings from LocalStorageService
      // For now returning empty map
      return const DataSuccess({});
    } catch (e, st) {
      return DataFailed(Exception(e.toString()), st);
    }
  }

  @override
  Future<DataState<bool>> initializeServices() async {
    try {
      // Initialize any required services here
      // For example: analytics, crash reporting, etc.
      return const DataSuccess(true);
    } catch (e, st) {
      return DataFailed(Exception(e.toString()), st);
    }
  }

  @override
  Future<DataState<InitStateModel>> getInitialState() async {
    try {
      final userResult = await getCachedUser();
      final settingsResult = await getCachedSettings();
      final servicesResult = await initializeServices();

      if (userResult is DataFailed) {
        return DataFailed(
          Exception(userResult.error.toString()),
          userResult.stackTrace ?? StackTrace.current,
        );
      }

      if (settingsResult is DataFailed) {
        return DataFailed(
          Exception(settingsResult.error.toString()),
          settingsResult.stackTrace ?? StackTrace.current,
        );
      }

      if (servicesResult is DataFailed) {
        return DataFailed(
          Exception(servicesResult.error.toString()),
          servicesResult.stackTrace ?? StackTrace.current,
        );
      }

      return DataSuccess(
        InitStateModel(
          isInitialized: true,
          user: userResult.data,
          cachedData: settingsResult.data ?? {},
        ),
      );
    } catch (e, st) {
      return DataFailed(Exception(e.toString()), st);
    }
  }
}
