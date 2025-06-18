import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/core/services/local_storage_service.dart';
import 'package:selo/shared/models/local_user_model.dart';
import 'package:selo/shared/models/user_model.dart';
import 'package:selo/features/profile/data/datasources/profile_interface.dart';
import 'package:selo/features/profile/data/models/profile_user.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:talker_flutter/talker_flutter.dart';

class FirebaseProfileRemoteDataSource implements ProfileInterface {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Talker _talker;

  FirebaseProfileRemoteDataSource(this._firestore, this._storage, this._talker);

  @override
  Future<DataState<List<AdvertModel>>> getMyAdverts(String uid) async {
    _talker.info('🔄 Fetching adverts for user: $uid');
    try {
      final snapshot =
          await _firestore
              .collection(FirebaseCollections.adverts)
              .where('ownerUid', isEqualTo: uid)
              .get();
      final List<AdvertModel> adverts =
          snapshot.docs.map((doc) => AdvertModel.fromJson(doc.data())).toList();
      _talker.info('✅ Successfully fetched ${adverts.length} adverts');
      return DataSuccess(adverts);
    } catch (e, stack) {
      _talker.error('❌ Failed to fetch adverts', e, stack);
      return DataFailed(Exception('Failed to fetch adverts: $e'), stack);
    }
  }

  @override
  Future<DataState<bool>> deleteAdvert(String uid) async {
    _talker.info('🔄 Deleting advert: $uid');
    try {
      await _firestore.collection(FirebaseCollections.adverts).doc(uid).update({
        'active': false,
      });
      _talker.info('✅ Successfully deleted advert');
      return DataSuccess(true);
    } catch (e, stack) {
      _talker.error('❌ Failed to delete advert', e, stack);
      return DataFailed(Exception('Failed to delete advert: $e'), stack);
    }
  }

  @override
  Future<DataState<bool>> deleteUser(String uid) async {
    _talker.info('🔄 Deleting user: $uid');
    try {
      await _firestore.collection(FirebaseCollections.users).doc(uid).set({
        'deletedAt': Timestamp.now(),
        'isDeleted': true,
      }, SetOptions(merge: true));
      _talker.info('✅ Successfully deleted user');
      return DataSuccess(true);
    } catch (e, stack) {
      _talker.error('❌ Failed to delete user', e, stack);
      return DataFailed(Exception('Failed to delete user: $e'), stack);
    }
  }

  // Удаление старого изображения
  Future<void> _deleteOldProfileImage(String? oldImageUrl) async {
    if (oldImageUrl == null || !oldImageUrl.startsWith('https')) {
      _talker.debug('ℹ️ No old image to delete or invalid URL: $oldImageUrl');
      return;
    }
    try {
      final ref = _storage.refFromURL(oldImageUrl);
      await ref.delete();
      _talker.debug('🗑️ Deleted old image: $oldImageUrl');
    } catch (e, stack) {
      _talker.error('⚠️ Failed to delete old image', e, stack);
      // Продолжаем, даже если удаление не удалось
    }
  }

  // Загрузка нового изображения
  Future<String?> _uploadProfileImage(
    String uid,
    String localPath,
    String? oldImageUrl,
  ) async {
    _talker.info('🔄 Uploading profile image for user: $uid');
    try {
      final file = File(localPath);
      _talker.debug('📁 Processing file: $localPath');

      if (!file.existsSync()) {
        throw Exception('Image file does not exist at $localPath');
      }

      final fileSize = await file.length();
      _talker.debug('📊 File size: $fileSize bytes');

      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Image file is too large (max 5MB): $fileSize bytes');
      }

      await _deleteOldProfileImage(oldImageUrl);

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final storageRef = _storage.ref().child('user_photos/$uid/$fileName');
      _talker.debug('📂 Storage path: user_photos/$uid/$fileName');

      final ext = fileName.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final metadata = SettableMetadata(contentType: contentType);
      final bytes = await file.readAsBytes();

      // Загрузка с повторными попытками
      String? downloadUrl;
      int retryCount = 0;
      while (retryCount < 3 && downloadUrl == null) {
        if (retryCount > 0) {
          _talker.debug('🔄 Retrying upload (attempt ${retryCount + 1})');
          await Future.delayed(Duration(seconds: 1));
        }

        try {
          final uploadTask = storageRef.putData(bytes, metadata);
          final snapshot = await uploadTask.timeout(Duration(seconds: 60));
          if (snapshot.state != TaskState.success) {
            throw Exception('Upload failed: ${snapshot.state}');
          }
          downloadUrl = await snapshot.ref.getDownloadURL();
          _talker.debug('✅ Uploaded image URL: $downloadUrl');
        } on FirebaseException catch (e, stack) {
          _talker.error('❌ Firebase error during upload', e, stack);
          if (retryCount == 2) {
            throw Exception('Failed to upload after 3 attempts: ${e.code}');
          }
        }
        retryCount++;
      }

      if (downloadUrl == null) {
        throw Exception('Failed to upload image after 3 attempts');
      }

      _talker.info('✅ Successfully uploaded profile image');
      return downloadUrl;
    } catch (e, stack) {
      _talker.error('❌ Failed to upload profile image', e, stack);
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<DataState<bool>> updateUser(UpdateUserModel updateUser) async {
    _talker.info('🔄 Updating user: ${updateUser.uid}');
    try {
      _talker.debug('📥 Checking user existence...');
      final user =
          await _firestore
              .collection(FirebaseCollections.users)
              .doc(updateUser.uid)
              .get();
      if (!user.exists) {
        _talker.error('❌ User not found: ${updateUser.uid}');
        return DataFailed(Exception('User not found'), StackTrace.current);
      }

      final userData = user.data();
      if (userData == null) {
        _talker.error('❌ User data is null for user: ${updateUser.uid}');
        return DataFailed(Exception('User data is null'), StackTrace.current);
      }

      String? profileImageUrl = updateUser.profileImage;
      final userModel = UserModel.fromFirestoreMap(userData);

      if (profileImageUrl != null && !profileImageUrl.startsWith('http')) {
        _talker.debug('📤 Uploading new profile image...');
        profileImageUrl = await _uploadProfileImage(
          updateUser.uid,
          profileImageUrl,
          userModel.profileImage,
        );
        if (profileImageUrl == null) {
          _talker.error('❌ Failed to upload profile image');
          return DataFailed(
            Exception('Failed to upload profile image'),
            StackTrace.current,
          );
        }
      }

      _talker.debug('📝 Updating user data...');
      final updatedUser = userModel.copyWith(
        name: updateUser.name,
        lastName: updateUser.lastName,
        phoneNumber: updateUser.phoneNumber,
        region: updateUser.region,
        district: updateUser.district,
        profileImage: profileImageUrl,
        updatedAt: Timestamp.now(),
      );

      await _firestore
          .collection(FirebaseCollections.users)
          .doc(updateUser.uid)
          .set(updatedUser.toFirestoreMap(), SetOptions(merge: true));

      _talker.debug('💾 Updating local storage...');
      await LocalStorageService.deleteUser();
      await LocalStorageService.saveUser(
        LocalUserModel.fromUserModel(updatedUser),
      );

      _talker.info('✅ Successfully updated user profile');
      return DataSuccess(true);
    } catch (e, stack) {
      _talker.error('❌ Failed to update user', e, stack);
      return DataFailed(Exception('Failed to update user: $e'), stack);
    }
  }
}
