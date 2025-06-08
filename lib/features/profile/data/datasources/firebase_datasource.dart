import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/features/authentication/data/models/local_user_model.dart';
import 'package:selo/features/authentication/data/models/user_model.dart';
import 'package:selo/features/profile/data/datasources/profile_interface.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/shared/models/advert_model.dart';

class FirebaseProfileRemoteDataSource implements ProfileInterface {
  final FirebaseFirestore _firestore;

  FirebaseProfileRemoteDataSource(this._firestore);

  @override
  Future<DataState<List<AdvertModel>>> getMyAdverts(String uid) async {
    try {
      final snapshot =
          await _firestore
              .collection(FirebaseCollections.adverts)
              .where('ownerUid', isEqualTo: uid)
              .get();
      final List<AdvertModel> adverts =
          snapshot.docs.map((doc) => AdvertModel.fromJson(doc.data())).toList();
      return DataSuccess(adverts);
    } catch (e) {
      return DataFailed(Exception(e), StackTrace.current);
    }
  }

  @override
  Future<DataState<bool>> deleteAdvert(String uid) async {
    try {
      await _firestore.collection(FirebaseCollections.adverts).doc(uid).update({
        'active': false,
      });
      return DataSuccess(true);
    } catch (e) {
      return DataFailed(Exception(e), StackTrace.current);
    }
  }

  @override
  Future<DataState<bool>> deleteUser(String uid) async {
    try {
      await _firestore.collection(FirebaseCollections.users).doc(uid).set({
        'deletedAt': Timestamp.now(),
        'isDeleted': true,
      }, SetOptions(merge: true));
      return DataSuccess(true);
    } catch (e) {
      return DataFailed(Exception(e), StackTrace.current);
    }
  }

  @override
  Future<DataState<bool>> updateUser(UpdateUserModel updateUser) async {
    try {
      final user =
          await _firestore
              .collection(FirebaseCollections.users)
              .doc(updateUser.uid)
              .get();
      if (user.exists) {
        final userData = user.data();
        if (userData != null) {
          final userModel = UserModel.fromFirestoreMap(userData);
          final updatedUser = userModel.copyWith(
            name: updateUser.name,
            lastName: updateUser.lastName,
            phoneNumber: updateUser.phoneNumber,
            region: updateUser.region,
            district: updateUser.district,
            profileImage: updateUser.profileImage,
            updatedAt: Timestamp.now(),
          );
          await _firestore
              .collection(FirebaseCollections.users)
              .doc(updateUser.uid)
              .set(updatedUser.toFirestoreMap(), SetOptions(merge: true));
          await LocalStorageService.deleteUser();
          await LocalStorageService.saveUser(
            LocalUserModel.fromUserModel(userModel),
          );
          return DataSuccess(true);
        }
      }
      return DataFailed(Exception('User not found'), StackTrace.current);
    } catch (e) {
      return DataFailed(Exception(e), StackTrace.current);
    }
  }
}
