import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'favourites_interface.dart';
import 'dart:io';

class FirebaseDatasource implements FavouritesInterface {
  final FirebaseFirestore _firestore;

  FirebaseDatasource(this._firestore);

  @override
  Future<DataState<List<AdvertModel>>> getFavourites(
    UserUidModel userUidModel,
  ) async {
    try {
      final user = _firestore
          .collection(FirebaseCollections.users)
          .doc(userUidModel.uid);

      final userDoc = await user.get();
      if (!userDoc.exists) {
        return DataFailed(Exception('User not found'), StackTrace.current);
      }
      final userData = userDoc.data();
      if (userData == null) {
        return DataFailed(Exception('User data is null'), StackTrace.current);
      }

      final likes = userData['likes'] as List<dynamic>? ?? [];
      final likesList = likes.map((e) => e.toString()).toList();

      final adverts = <AdvertModel>[];

      for (final likeUid in likesList) {
        final advertDoc =
            await _firestore
                .collection(FirebaseCollections.adverts)
                .doc(likeUid)
                .get();

        if (advertDoc.exists) {
          final data = advertDoc.data();
          if (data != null) {
            adverts.add(AdvertModel.fromJson(data));
          }
        }
      }

      return DataSuccess(adverts);
    } catch (e) {
      print('❌ Error in getFavourites: $e');
      return DataFailed(Exception(e), StackTrace.current);
    }
  }

  @override
  Future<DataState<bool>> addToFavourites(
    FavouritesModel favouritesModel,
  ) async {
    try {
      final userRef = _firestore
          .collection(FirebaseCollections.users)
          .doc(favouritesModel.userUid.uid);

      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        return DataFailed(Exception('User not found'), StackTrace.current);
      }

      final userData = userDoc.data();
      if (userData == null) {
        return DataFailed(Exception('User data is null'), StackTrace.current);
      }

      // Get current likes array
      final likes =
          (userData['likes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();

      // Check if advert is already in likes
      if (likes.contains(favouritesModel.advertUid.uid)) {
        return DataFailed(
          Exception('Advert already in favourites'),
          StackTrace.current,
        );
      }

      // Add new advert to likes
      likes.add(favouritesModel.advertUid.uid);
      final advertRef = _firestore
          .collection(FirebaseCollections.adverts)
          .doc(favouritesModel.advertUid.uid);
      // Update user document
      await userRef.update({'likes': likes});
      await advertRef.update({'likes': FieldValue.increment(1)});
      return DataSuccess(true);
    } catch (e) {
      print('❌ Error in addToFavourites: $e');
      return DataFailed(Exception(e), StackTrace.current);
    }
  }

  @override
  Future<DataState<bool>> removeFromFavourites(
    FavouritesModel favouritesModel,
  ) async {
    try {
      final userRef = _firestore
          .collection(FirebaseCollections.users)
          .doc(favouritesModel.userUid.uid);

      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        return DataFailed(Exception('User not found'), StackTrace.current);
      }

      final userData = userDoc.data();
      if (userData == null) {
        return DataFailed(Exception('User data is null'), StackTrace.current);
      }

      // Get current likes array
      final likes =
          (userData['likes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();

      // Check if advert is in likes
      if (!likes.contains(favouritesModel.advertUid.uid)) {
        return DataFailed(
          Exception('Advert not in favourites'),
          StackTrace.current,
        );
      }

      // Remove advert from likes
      likes.remove(favouritesModel.advertUid.uid);
      final advertRef = _firestore
          .collection(FirebaseCollections.adverts)
          .doc(favouritesModel.advertUid.uid);
      // Update user document
      await userRef.update({'likes': likes});
      await advertRef.update({'likes': FieldValue.increment(-1)});
      return DataSuccess(true);
    } catch (e) {
      print('❌ Error in removeFromFavourites: $e');
      return DataFailed(Exception(e), StackTrace.current);
    }
  }

  @override
  Future<DataState<bool>> toggleFavourite(
    FavouritesModel favouritesModel,
  ) async {
    try {
      final userRef = _firestore
          .collection(FirebaseCollections.users)
          .doc(favouritesModel.userUid.uid);
      final advertRef = _firestore
          .collection(FirebaseCollections.adverts)
          .doc(favouritesModel.advertUid.uid);

      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        return DataFailed(Exception('User not found'), StackTrace.current);
      }

      final userData = userDoc.data();
      if (userData == null) {
        return DataFailed(Exception('User data is null'), StackTrace.current);
      }

      // Get current likes array
      final likes =
          (userData['likes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();

      // Toggle advert in likes
      if (likes.contains(favouritesModel.advertUid.uid)) {
        likes.remove(favouritesModel.advertUid.uid);
        await advertRef.update({'likes': FieldValue.increment(-1)});
      } else {
        likes.add(favouritesModel.advertUid.uid);
        await advertRef.update({'likes': FieldValue.increment(1)});
      }

      // Update user document
      await userRef.update({'likes': likes});
      return DataSuccess(true);
    } catch (e) {
      print('❌ Error in toggleFavourite: $e');
      return DataFailed(Exception(e), StackTrace.current);
    }
  }
}
