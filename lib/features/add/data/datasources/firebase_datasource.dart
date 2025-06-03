import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/features/add/data/datasources/categories_interface.dart';
import 'package:selo/features/add/data/models/advert_model.dart';
import 'dart:io';

class FirebaseDatasource implements AdvertInteface, CategoriesInteface {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  FirebaseDatasource(this._firestore, this._storage);

  Future<String?> _uploadSingleImage(
    File file,
    String path,
    String advertId,
  ) async {
    try {
      if (!file.existsSync()) {
        print('File does not exist: $path');
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

      final bytes = await file.readAsBytes();
      final uploadTask = ref.putData(bytes, metadata);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase error during upload: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('Error uploading single image: $e');
      return null;
    }
  }

  Future<List<String>> _uploadImages(
    List<String> paths,
    String advertId,
  ) async {
    final imageUrls = <String>[];

    try {
      for (var path in paths) {
        if (path.isEmpty) continue;

        final file = File(path);
        if (!await file.exists()) {
          print('File does not exist: $path');
          continue;
        }

        // Try uploading with retries
        String? downloadUrl;
        int retryCount = 0;
        while (retryCount < 3 && downloadUrl == null) {
          if (retryCount > 0) {
            print('Retrying upload for $path (attempt ${retryCount + 1})');
            await Future.delayed(Duration(seconds: 1)); // Wait before retry
          }

          downloadUrl = await _uploadSingleImage(file, path, advertId);
          retryCount++;
        }

        if (downloadUrl != null) {
          imageUrls.add(downloadUrl);
        }
      }

      if (paths.isNotEmpty && imageUrls.isEmpty) {
        throw Exception('Failed to upload any images after retries');
      }

      return imageUrls;
    } catch (e) {
      print('Error in _uploadImages: $e');
      rethrow;
    }
  }

  @override
  Future<DataState<AdvertModel>> createAd(AdvertModel advert) async {
    try {
      final docRef = _firestore.collection(FirebaseCollections.adverts).doc();
      final now = Timestamp.now();

      // Upload images first
      List<String> imageUrls = [];
      if (advert.images.isNotEmpty) {
        try {
          imageUrls = await _uploadImages(advert.images, docRef.id);
          if (imageUrls.isEmpty) {
            return DataFailed(
              Exception('Failed to upload images - no successful uploads'),
              StackTrace.current,
            );
          }
        } catch (e) {
          print('Error uploading images: $e');
          return DataFailed(
            Exception('Failed to upload images: $e'),
            StackTrace.current,
          );
        }
      }

      final newAdvert = advert.copyWith(
        uid: docRef.id,
        images: imageUrls,
        createdDate: now,
        updatedDate: now,
      );

      await docRef.set(newAdvert.toMap());
      return DataSuccess(newAdvert);
    } catch (e, st) {
      print('Error in createAd: $e');
      print('Stack trace: $st');
      return DataFailed(Exception(e.toString()), st);
    }
  }

  @override
  Future<DataState<List<AdCategory>>> getCategories() async {
    try {
      final ref = _firestore.collection(FirebaseCollections.categories);
      final snapshot = await ref.get();

      // Log the raw data from Firestore
      print('Raw Firestore data:');
      for (var doc in snapshot.docs) {
        print('Document ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }

      final categories =
          snapshot.docs.map((doc) {
            try {
              return AdCategory.fromMap(doc.data());
            } catch (e) {
              print('Error parsing category document ${doc.id}: $e');
              rethrow;
            }
          }).toList();

      return DataSuccess(categories);
    } catch (e, st) {
      print('Error in getCategories: $e');
      print('Stack trace: $st');
      return DataFailed(Exception(e.toString()), st);
    }
  }
}
