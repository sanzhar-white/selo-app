import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/features/add/data/datasources/categories_interface.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'dart:io';

import 'package:talker_flutter/talker_flutter.dart';

class FirebaseDatasource implements AdvertInteface, CategoriesInteface {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Talker _talker;

  FirebaseDatasource(this._firestore, this._storage, this._talker);

  Future<String?> _uploadSingleImage(
    File file,
    String path,
    String advertId,
  ) async {
    try {
      if (!file.existsSync()) {
        _talker.error('❌ File does not exist: $path');
        return null;
      }

      final fileName =
          DateTime.now().millisecondsSinceEpoch.toString() +
          '_' +
          file.uri.pathSegments.last;

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
      _talker.error('❌ Firebase error during upload: ${e.code}', e, stack);
      return null;
    } catch (e, stack) {
      _talker.error('❌ Error uploading single image', e, stack);
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
      for (var path in paths) {
        if (path.isEmpty) continue;

        final file = File(path);
        if (!await file.exists()) {
          _talker.error('❌ File does not exist: $path');
          continue;
        }

        String? downloadUrl;
        int retryCount = 0;
        while (retryCount < 3 && downloadUrl == null) {
          if (retryCount > 0) {
            _talker.debug(
              '🔄 Retrying upload for $path (attempt ${retryCount + 1})',
            );
            await Future.delayed(Duration(seconds: 1));
          }

          downloadUrl = await _uploadSingleImage(file, path, advertId);
          retryCount++;
        }

        if (downloadUrl != null) {
          imageUrls.add(downloadUrl);
          _talker.debug('✅ Successfully uploaded image: $path');
        } else {
          _talker.error('❌ Failed to upload image after retries: $path');
        }
      }

      if (paths.isNotEmpty && imageUrls.isEmpty) {
        _talker.error('❌ Failed to upload any images after retries');
        throw Exception('Failed to upload any images after retries');
      }

      _talker.info('✅ Successfully uploaded ${imageUrls.length} images');
      return imageUrls;
    } catch (e, stack) {
      _talker.error('❌ Error in _uploadImages', e, stack);
      rethrow;
    }
  }

  @override
  Future<DataState<AdvertModel>> createAd(AdvertModel advert) async {
    _talker.info('🔄 Creating new advert');
    try {
      final docRef = _firestore.collection(FirebaseCollections.adverts).doc();
      final now = Timestamp.now();

      List<String> imageUrls = [];
      if (advert.images.isNotEmpty) {
        _talker.debug(
          '📤 Starting image upload for ${advert.images.length} images',
        );
        try {
          imageUrls = await _uploadImages(advert.images, docRef.id);
          if (imageUrls.isEmpty) {
            _talker.error('❌ Failed to upload images - no successful uploads');
            return DataFailed(
              Exception('Failed to upload images - no successful uploads'),
              StackTrace.current,
            );
          }
        } catch (e, stack) {
          _talker.error('❌ Error uploading images', e, stack);
          return DataFailed(Exception('Failed to upload images: $e'), stack);
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
      _talker.error('❌ Error in createAd', e, stack);
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
      for (var doc in snapshot.docs) {
        _talker.debug('📄 Document ID: ${doc.id}');
        _talker.debug('📄 Data: ${doc.data()}');
      }

      final categories =
          snapshot.docs.map((doc) {
            try {
              return AdCategory.fromMap(doc.data());
            } catch (e, stack) {
              _talker.error(
                '❌ Error parsing category document ${doc.id}',
                e,
                stack,
              );
              rethrow;
            }
          }).toList();

      _talker.info('✅ Successfully fetched ${categories.length} categories');
      return DataSuccess(categories);
    } catch (e, stack) {
      _talker.error('❌ Error in getCategories', e, stack);
      return DataFailed(Exception(e.toString()), stack);
    }
  }
}
