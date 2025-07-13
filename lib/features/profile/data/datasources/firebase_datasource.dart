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
import 'package:selo/core/constants/error_message.dart';

class FirebaseProfileRemoteDataSource implements ProfileInterface {
  FirebaseProfileRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required Talker talker,
  }) : _firestore = firestore,
       _storage = storage,
       _talker = talker;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Talker _talker;

  @override
  Future<DataState<List<AdvertModel>>> getMyAdverts(
    String uid, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    _talker.info('Fetching adverts for user: $uid');
    try {
      var query = _firestore
          .collection(FirebaseCollections.adverts)
          .where('active', isEqualTo: true)
          .where('ownerUid', isEqualTo: uid)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get().timeout(
        FirebaseConstants.operationTimeout,
      );
      final adverts =
          snapshot.docs.map((doc) => AdvertModel.fromJson(doc.data())).toList();
      _talker.info('Successfully fetched ${adverts.length} adverts');
      return DataSuccess(adverts);
    } on Exception catch (e, stack) {
      _talker.error(ErrorMessages.failedToFetchAdverts, e, stack);
      return DataFailed(
        Exception('${ErrorMessages.failedToFetchAdverts}: $e'),
        stack,
      );
    }
  }

  @override
  Future<DataState<bool>> deleteAdvert(String uid) async {
    _talker.info('Deleting advert: $uid');
    try {
      await _firestore
          .collection(FirebaseCollections.adverts)
          .doc(uid)
          .update({'active': false})
          .timeout(FirebaseConstants.operationTimeout);
      _talker.info('Successfully deleted advert');
      await _firestore
          .collection(FirebaseCollections.adverts)
          .doc(uid)
          .update({'deletedAt': Timestamp.now()})
          .timeout(FirebaseConstants.operationTimeout);
      return const DataSuccess(true);
    } on Exception catch (e, stack) {
      _talker.error(ErrorMessages.failedToDeleteAdvert, e, stack);
      return DataFailed(
        Exception('${ErrorMessages.failedToDeleteAdvert}: $e'),
        stack,
      );
    }
  }

  @override
  Future<DataState<bool>> deleteUser(String uid) async {
    _talker.info('Deleting user: $uid');
    try {
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(uid)
          .set({
            'deletedAt': Timestamp.now(),
            'isDeleted': true,
          }, SetOptions(merge: true))
          .timeout(FirebaseConstants.operationTimeout);
      _talker.info('Successfully deleted user');
      return const DataSuccess(true);
    } on Exception catch (e, stack) {
      _talker.error(ErrorMessages.failedToDeleteUser, e, stack);
      return DataFailed(
        Exception('${ErrorMessages.failedToDeleteUser}: $e'),
        stack,
      );
    }
  }

  Future<void> _deleteOldProfileImage(String? oldImageUrl) async {
    if (oldImageUrl == null || !oldImageUrl.startsWith('https')) {
      _talker.debug('No old image to delete or invalid URL: $oldImageUrl');
      return;
    }
    try {
      final ref = _storage.refFromURL(oldImageUrl);
      await ref.delete();
      _talker.debug('Deleted old image: $oldImageUrl');
    } on Exception catch (e, stack) {
      _talker.error('Failed to delete old image', e, stack);
    }
  }

  Future<String?> _uploadProfileImage(
    String uid,
    String localPath,
    String? oldImageUrl,
  ) async {
    _talker.info('Uploading profile image for user: $uid');
    try {
      final file = File(localPath);
      _talker.debug('Processing file: $localPath');

      if (!file.existsSync()) {
        _talker.error(ErrorMessages.imageFileNotExist);
        throw Exception(ErrorMessages.imageFileNotExist);
      }

      final fileSize = await file.length();
      if (fileSize > FirebaseConstants.maxImageSizeBytes) {
        _talker.error('${ErrorMessages.imageTooLarge}: $fileSize bytes');
        throw Exception('${ErrorMessages.imageTooLarge}: $fileSize bytes');
      }

      await _deleteOldProfileImage(oldImageUrl);

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final storageRef = _storage.ref().child(
        '${FirebaseCollections.user_photos}/$uid/$fileName',
      );
      _talker.debug(
        'Storage path: ${FirebaseCollections.user_photos}/$uid/$fileName',
      );

      final ext = fileName.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final metadata = SettableMetadata(contentType: contentType);
      final fileBytes = await file.readAsBytes();

      String? downloadUrl;
      for (
        var retryCount = 0;
        retryCount < FirebaseConstants.maxUploadRetries;
        retryCount++
      ) {
        if (retryCount > 0) {
          _talker.debug('Retrying upload (attempt ${retryCount + 1})');
          await Future.delayed(FirebaseConstants.uploadRetryDelay);
        }

        try {
          final uploadTask = await storageRef
              .putData(fileBytes, metadata)
              .timeout(FirebaseConstants.operationTimeout);
          downloadUrl = await uploadTask.ref.getDownloadURL();
          _talker.debug('Uploaded image URL: $downloadUrl');
          break;
        } on FirebaseException catch (e, stack) {
          _talker.error('Firebase error during upload', e, stack);
          if (retryCount == FirebaseConstants.maxUploadRetries - 1) {
            throw Exception(
              'Failed to upload after ${FirebaseConstants.maxUploadRetries} attempts: ${e.code}',
            );
          }
        }
      }

      if (downloadUrl == null) {
        throw Exception(
          'Failed to upload image after ${FirebaseConstants.maxUploadRetries} attempts',
        );
      }

      _talker.info('Successfully uploaded profile image');
      return downloadUrl;
    } on Exception catch (e, stack) {
      _talker.error(ErrorMessages.failedToUploadImage, e, stack);
      throw Exception('${ErrorMessages.failedToUploadImage}: $e');
    }
  }

  @override
  Future<DataState<bool>> updateUser(UpdateUserModel updateUser) async {
    _talker.info('Updating user: ${updateUser.uid}');
    try {
      final userDoc = await _firestore
          .collection(FirebaseCollections.users)
          .doc(updateUser.uid)
          .get()
          .timeout(FirebaseConstants.operationTimeout);

      if (!userDoc.exists) {
        _talker.error(ErrorMessages.userNotFound);
        return DataFailed(
          Exception(ErrorMessages.userNotFound),
          StackTrace.current,
        );
      }

      var profileImageUrl = updateUser.profileImage;
      if (profileImageUrl != null && !profileImageUrl.startsWith('http')) {
        profileImageUrl = await _uploadProfileImage(
          updateUser.uid,
          profileImageUrl,
          userDoc.data()?['profileImage'] as String?,
        );
        if (profileImageUrl == null) {
          _talker.error(ErrorMessages.failedToUploadImage);
          return DataFailed(
            Exception(ErrorMessages.failedToUploadImage),
            StackTrace.current,
          );
        }
      }

      final likesList = userDoc.data()?['likes'];

      final updatedUser = UserModel(
        uid: updateUser.uid,
        name: updateUser.name ?? (userDoc.data()?['name'] as String? ?? ''),
        lastName:
            updateUser.lastName ??
            (userDoc.data()?['lastName'] as String? ?? ''),
        phoneNumber:
            updateUser.phoneNumber ??
            (userDoc.data()?['phoneNumber'] as String? ?? ''),
        region: updateUser.region ?? (userDoc.data()?['region'] as int? ?? 0),
        district:
            updateUser.district ?? (userDoc.data()?['district'] as int? ?? 0),
        profileImage:
            profileImageUrl ??
            (userDoc.data()?['profileImage'] as String? ?? ''),
        createdAt:
            (userDoc.data()?['createdAt'] as Timestamp?) ?? Timestamp.now(),
        likes:
            likesList is List
                ? List<String>.from(likesList.map((e) => e.toString()))
                : [],
        updatedAt: Timestamp.now(),
      );

      await _firestore
          .collection(FirebaseCollections.users)
          .doc(updateUser.uid)
          .set(updatedUser.toFirestoreMap(), SetOptions(merge: true))
          .timeout(FirebaseConstants.operationTimeout);

      await _updateLocalStorage(updatedUser);

      _talker.info('Successfully updated user profile');
      return const DataSuccess(true);
    } on Exception catch (e, stack) {
      _talker.error(ErrorMessages.failedToUpdateUser, e, stack);
      return DataFailed(
        Exception('${ErrorMessages.failedToUpdateUser}: $e'),
        stack,
      );
    }
  }

  Future<void> _updateLocalStorage(UserModel updatedUser) async {
    try {
      await LocalStorageService.deleteUser();
      await LocalStorageService.saveUser(
        LocalUserModel.fromUserModel(updatedUser),
      );
      _talker.debug('Updated local storage');
    } on Exception catch (e, stack) {
      _talker.error('Failed to update local storage', e, stack);
    }
  }
}
