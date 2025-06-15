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

class FirebaseProfileRemoteDataSource implements ProfileInterface {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseProfileRemoteDataSource(this._firestore, this._storage);

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
      print('Fetch adverts error: $e');
      return DataFailed(
        Exception('Failed to fetch adverts: $e'),
        StackTrace.current,
      );
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
      print('Delete advert error: $e');
      return DataFailed(
        Exception('Failed to delete advert: $e'),
        StackTrace.current,
      );
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
      print('Delete user error: $e');
      return DataFailed(
        Exception('Failed to delete user: $e'),
        StackTrace.current,
      );
    }
  }

  // Удаление старого изображения
  Future<void> _deleteOldProfileImage(String? oldImageUrl) async {
    if (oldImageUrl == null || !oldImageUrl.startsWith('https')) {
      print('No old image to delete or invalid URL: $oldImageUrl');
      return;
    }
    try {
      final ref = _storage.refFromURL(oldImageUrl);
      await ref.delete();
      print('Deleted old image: $oldImageUrl');
    } catch (e) {
      print('Failed to delete old image: $e');
      // Продолжаем, даже если удаление не удалось
    }
  }

  // Загрузка нового изображения
  Future<String?> _uploadProfileImage(
    String uid,
    String localPath,
    String? oldImageUrl,
  ) async {
    try {
      // Проверка файла
      final file = File(localPath);
      print('Uploading file: $localPath');
      if (!file.existsSync()) {
        throw Exception('Image file does not exist at $localPath');
      }
      final fileSize = await file.length();
      print('File size: $fileSize bytes');
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('Image file is too large (max 5MB): $fileSize bytes');
      }

      // Удаляем старое изображение
      await _deleteOldProfileImage(oldImageUrl);

      // Подготовка файла
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';
      final storageRef = _storage.ref().child('user_photos/$uid/$fileName');
      print('Storage path: user_photos/$uid/$fileName');

      final ext = fileName.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final metadata = SettableMetadata(contentType: contentType);
      final bytes = await file.readAsBytes();

      // Загрузка с повторными попытками
      String? downloadUrl;
      int retryCount = 0;
      while (retryCount < 3 && downloadUrl == null) {
        if (retryCount > 0) {
          print('Retrying upload for $localPath (attempt ${retryCount + 1})');
          await Future.delayed(Duration(seconds: 1));
        }

        try {
          final uploadTask = storageRef.putData(bytes, metadata);
          final snapshot = await uploadTask.timeout(Duration(seconds: 60));
          if (snapshot.state != TaskState.success) {
            throw Exception('Upload failed: ${snapshot.state}');
          }
          downloadUrl = await snapshot.ref.getDownloadURL();
          print('Uploaded image URL: $downloadUrl');
        } on FirebaseException catch (e) {
          print('Firebase error during upload: ${e.code} - ${e.message}');
          if (retryCount == 2) {
            throw Exception('Failed to upload after 3 attempts: ${e.code}');
          }
        }
        retryCount++;
      }

      if (downloadUrl == null) {
        throw Exception('Failed to upload image after 3 attempts');
      }

      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<DataState<bool>> updateUser(UpdateUserModel updateUser) async {
    try {
      // Проверяем существование пользователя
      final user =
          await _firestore
              .collection(FirebaseCollections.users)
              .doc(updateUser.uid)
              .get();
      if (!user.exists) {
        return DataFailed(Exception('User not found'), StackTrace.current);
      }
      final userData = user.data();
      if (userData == null) {
        return DataFailed(Exception('User data is null'), StackTrace.current);
      }

      String? profileImageUrl = updateUser.profileImage;
      final userModel = UserModel.fromFirestoreMap(userData);

      // Загружаем новое изображение, если это локальный путь
      if (profileImageUrl != null && !profileImageUrl.startsWith('http')) {
        profileImageUrl = await _uploadProfileImage(
          updateUser.uid,
          profileImageUrl,
          userModel.profileImage, // Передаём старый URL для удаления
        );
        if (profileImageUrl == null) {
          return DataFailed(
            Exception('Failed to upload profile image'),
            StackTrace.current,
          );
        }
      }

      // Формируем обновлённую модель пользователя
      final updatedUser = userModel.copyWith(
        name: updateUser.name,
        lastName: updateUser.lastName,
        phoneNumber: updateUser.phoneNumber,
        region: updateUser.region,
        district: updateUser.district,
        profileImage: profileImageUrl,
        updatedAt: Timestamp.now(),
      );

      // Сохраняем в Firestore
      await _firestore
          .collection(FirebaseCollections.users)
          .doc(updateUser.uid)
          .set(updatedUser.toFirestoreMap(), SetOptions(merge: true));

      // Обновляем локальное хранилище
      await LocalStorageService.deleteUser();
      await LocalStorageService.saveUser(
        LocalUserModel.fromUserModel(updatedUser),
      );

      return DataSuccess(true);
    } catch (e) {
      print('Update user error: $e');
      return DataFailed(
        Exception('Failed to update user: $e'),
        StackTrace.current,
      );
    }
  }
}
