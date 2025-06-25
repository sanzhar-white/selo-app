import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/features/add/data/datasources/categories_interface.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'dart:io';

import 'package:talker_flutter/talker_flutter.dart';

class FirebaseDatasource implements AdvertInteface, CategoriesInteface {

  FirebaseDatasource(this._firestore, this._storage, this._talker);
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Talker _talker;

  Future<String?> _uploadSingleImage(
    File file,
    String path,
    String advertId,
  ) async {
    try {
      if (!file.existsSync()) {
        _talker.error('${ErrorMessages.fileDoesNotExist}: $path');
        return null;
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}';

      final ref = _storage.ref().child(
        '${FirebaseCollections.adverts}/$advertId/$fileName',
      );

      final ext = fileName.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final metadata = SettableMetadata(contentType: contentType);

      _talker.debug('📤 Uploading image: $fileName');
      final bytes = await file.readAsBytes();
      final uploadTask = ref.putData(bytes, metadata);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      _talker.debug('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e, stack) {
      _talker.error(
        '${ErrorMessages.firebaseErrorDuringUpload}: ${e.code}',
        e,
        stack,
      );
      return null;
    } catch (e, stack) {
      _talker.error(ErrorMessages.errorUploadingSingleImage, e, stack);
      return null;
    }
  }

  Future<List<String>> _uploadImages(
    List<String> paths,
    String advertId,
  ) async {
    final imageUrls = <String>[];
    _talker.info('🔄 Starting image upload for advert: $advertId');

    try {
      for (final path in paths) {
        if (path.isEmpty) continue;

        final file = File(path);
        if (!await file.exists()) {
          _talker.error('${ErrorMessages.fileDoesNotExist}: $path');
          continue;
        }

        String? downloadUrl;
        var retryCount = 0;
        while (retryCount < 3 && downloadUrl == null) {
          if (retryCount > 0) {
            _talker.debug(
              '🔄 Retrying upload for $path (attempt ${retryCount + 1})',
            );
            await Future.delayed(const Duration(seconds: 1));
          }

          downloadUrl = await _uploadSingleImage(file, path, advertId);
          retryCount++;
        }

        if (downloadUrl != null) {
          imageUrls.add(downloadUrl);
          _talker.debug('✅ Successfully uploaded image: $path');
        } else {
          _talker.error(
            '${ErrorMessages.failedToUploadImageAfterRetries}: $path',
          );
        }
      }

      if (paths.isNotEmpty && imageUrls.isEmpty) {
        _talker.error(ErrorMessages.failedToUploadAnyImages);
        throw Exception(ErrorMessages.failedToUploadAnyImages);
      }

      _talker.info('✅ Successfully uploaded ${imageUrls.length} images');
      return imageUrls;
    } catch (e, stack) {
      _talker.error(ErrorMessages.errorInUploadImages, e, stack);
      rethrow;
    }
  }

  @override
  Future<DataState<AdvertModel>> createAd(AdvertModel advert) async {
    _talker.info('🔄 Creating new advert');
    try {
      final docRef = _firestore.collection(FirebaseCollections.adverts).doc();
      final now = Timestamp.now();

      var imageUrls = <String>[];
      if (advert.images.isNotEmpty) {
        _talker.debug(
          '📤 Starting image upload for ${advert.images.length} images',
        );
        try {
          imageUrls = await _uploadImages(advert.images, docRef.id);
          if (imageUrls.isEmpty) {
            _talker.error(ErrorMessages.failedToUploadImagesNoSuccess);
            return DataFailed(
              Exception(ErrorMessages.failedToUploadImagesNoSuccess),
              StackTrace.current,
            );
          }
        } catch (e, stack) {
          _talker.error(ErrorMessages.errorUploadingImages, e, stack);
          return DataFailed(
            Exception('${ErrorMessages.errorUploadingImages}: $e'),
            stack,
          );
        }
      }

      final newAdvert = advert.copyWith(
        uid: docRef.id,
        images: imageUrls,
        createdAt: now,
        updatedAt: now,
      );

      _talker.debug('📝 Saving advert to Firestore: ${docRef.id}');
      await docRef.set(newAdvert.toMap());
      _talker.info('✅ Successfully created advert: ${docRef.id}');
      return DataSuccess(newAdvert);
    } catch (e, stack) {
      _talker.error(ErrorMessages.errorInCreateAd, e, stack);
      return DataFailed(Exception(e.toString()), stack);
    }
  }

  @override
  Future<DataState<List<AdCategory>>> getCategories() async {
    _talker.info('🔄 Fetching categories');
    try {
      final ref = _firestore.collection(FirebaseCollections.categories);
      final snapshot = await ref.get();

      _talker.debug('📋 Raw Firestore data:');
      for (final doc in snapshot.docs) {
        _talker.debug('📄 Document ID: ${doc.id}');
        _talker.debug('📄 Data: ${doc.data()}');
      }

      final categories =
          snapshot.docs.map((doc) {
            try {
              return AdCategory.fromMap(doc.data());
            } catch (e, stack) {
              _talker.error(
                '${ErrorMessages.errorParsingCategory} ${doc.id}',
                e,
                stack,
              );
              rethrow;
            }
          }).toList();

      _talker.info('✅ Successfully fetched ${categories.length} categories');
      return DataSuccess(categories);
    } catch (e, stack) {
      _talker.error(ErrorMessages.errorInGetCategories, e, stack);
      return DataFailed(Exception(e.toString()), stack);
    }
  }
}
