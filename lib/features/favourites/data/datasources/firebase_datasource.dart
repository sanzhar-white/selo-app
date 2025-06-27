import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/core/constants/error_message.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/favourites/data/model/favourites_model.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'favourites_interface.dart';
import 'dart:io';

class FirebaseDatasource implements FavouritesInterface {
  FirebaseDatasource(this._firestore, this._talker);
  final FirebaseFirestore _firestore;
  final Talker _talker;

  @override
  Future<DataState<List<AdvertModel>>> getFavourites(
    UserUidModel userUidModel,
  ) async {
    _talker.info('🔄 Getting favourites for user: ${userUidModel.uid}');
    try {
      final user = _firestore
          .collection(FirebaseCollections.users)
          .doc(userUidModel.uid);

      _talker.debug('📥 Fetching user document...');
      final userDoc = await user.get();
      if (!userDoc.exists) {
        _talker.error('${ErrorMessages.userNotFound} ${userUidModel.uid}');
        return DataFailed(
          Exception(ErrorMessages.userNotFound),
          StackTrace.current,
        );
      }

      final userData = userDoc.data();
      if (userData == null) {
        _talker.error(
          '${ErrorMessages.userDataIsNullForUser} ${userUidModel.uid}',
        );
        return DataFailed(
          Exception(ErrorMessages.userDataIsNull),
          StackTrace.current,
        );
      }

      final likes = userData['likes'] as List<dynamic>? ?? [];
      final likesList = likes.map((e) => e.toString()).toList();
      _talker.debug('📋 Found ${likesList.length} liked adverts');

      final adverts = <AdvertModel>[];

      for (final likeUid in likesList) {
        _talker.debug('📥 Fetching advert: $likeUid');
        final advertDoc =
            await _firestore
                .collection(FirebaseCollections.adverts)
                .doc(likeUid)
                .get();

        if (advertDoc.exists) {
          final data = advertDoc.data();
          if (data != null) {
            adverts.add(AdvertModel.fromJson(data));
            _talker.debug('✅ Successfully loaded advert: $likeUid');
          }
        } else {
          _talker.warning('Advert not found: $likeUid');
        }
      }

      _talker.info('✅ Successfully retrieved ${adverts.length} favourites');
      return DataSuccess(adverts);
    } on Exception catch (e, stack) {
      _talker.error(ErrorMessages.errorInGetFavourites, e, stack);
      return DataFailed(Exception(e), stack);
    }
  }

  @override
  Future<DataState<bool>> addToFavourites(
    FavouritesModel favouritesModel,
  ) async {
    _talker.info(
      '🔄 Adding to favourites - User: ${favouritesModel.userUid.uid}, Advert: ${favouritesModel.advertUid.uid}',
    );
    try {
      final userRef = _firestore
          .collection(FirebaseCollections.users)
          .doc(favouritesModel.userUid.uid);

      _talker.debug('📥 Fetching user document...');
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        _talker.error(
          '${ErrorMessages.userNotFound} ${favouritesModel.userUid.uid}',
        );
        return DataFailed(
          Exception(ErrorMessages.userNotFound),
          StackTrace.current,
        );
      }

      final userData = userDoc.data();
      if (userData == null) {
        _talker.error(
          '${ErrorMessages.userDataIsNullForUser} ${favouritesModel.userUid.uid}',
        );
        return DataFailed(
          Exception(ErrorMessages.userDataIsNull),
          StackTrace.current,
        );
      }

      final likes =
          (userData['likes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();

      if (likes.contains(favouritesModel.advertUid.uid)) {
        _talker.warning(
          'Advert already in favourites: ${favouritesModel.advertUid.uid}',
        );
        return DataFailed(
          Exception('Advert already in favourites'),
          StackTrace.current,
        );
      }

      likes.add(favouritesModel.advertUid.uid);
      final advertRef = _firestore
          .collection(FirebaseCollections.adverts)
          .doc(favouritesModel.advertUid.uid);

      _talker.debug('📝 Updating user document and advert likes...');
      await userRef.update({'likes': likes});
      await advertRef.update({'likes': FieldValue.increment(1)});

      _talker.info('✅ Successfully added to favourites');
      return const DataSuccess(true);
    } on Exception catch (e, stack) {
      _talker.error(ErrorMessages.errorInAddToFavourites, e, stack);
      return DataFailed(Exception(e), stack);
    }
  }

  @override
  Future<DataState<bool>> removeFromFavourites(
    FavouritesModel favouritesModel,
  ) async {
    _talker.info(
      '🔄 Removing from favourites - User: ${favouritesModel.userUid.uid}, Advert: ${favouritesModel.advertUid.uid}',
    );
    try {
      final userRef = _firestore
          .collection(FirebaseCollections.users)
          .doc(favouritesModel.userUid.uid);

      _talker.debug('📥 Fetching user document...');
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        _talker.error(
          '${ErrorMessages.userNotFound} ${favouritesModel.userUid.uid}',
        );
        return DataFailed(
          Exception(ErrorMessages.userNotFound),
          StackTrace.current,
        );
      }

      final userData = userDoc.data();
      if (userData == null) {
        _talker.error(
          '${ErrorMessages.userDataIsNullForUser} ${favouritesModel.userUid.uid}',
        );
        return DataFailed(
          Exception(ErrorMessages.userDataIsNull),
          StackTrace.current,
        );
      }

      final likes =
          (userData['likes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();

      if (!likes.contains(favouritesModel.advertUid.uid)) {
        _talker.warning(
          'Advert not in favourites: ${favouritesModel.advertUid.uid}',
        );
        return DataFailed(
          Exception('Advert not in favourites'),
          StackTrace.current,
        );
      }

      likes.remove(favouritesModel.advertUid.uid);
      final advertRef = _firestore
          .collection(FirebaseCollections.adverts)
          .doc(favouritesModel.advertUid.uid);

      _talker.debug('📝 Updating user document and advert likes...');
      await userRef.update({'likes': likes});
      await advertRef.update({'likes': FieldValue.increment(-1)});

      _talker.info('✅ Successfully removed from favourites');
      return const DataSuccess(true);
    } on Exception catch (e, stack) {
      _talker.error(ErrorMessages.errorInRemoveFromFavourites, e, stack);
      return DataFailed(Exception(e), stack);
    }
  }

  @override
  Future<DataState<bool>> toggleFavourite(
    FavouritesModel favouritesModel,
  ) async {
    _talker.info(
      '🔄 Toggling favourite - User: ${favouritesModel.userUid.uid}, Advert: ${favouritesModel.advertUid.uid}',
    );
    try {
      final userRef = _firestore
          .collection(FirebaseCollections.users)
          .doc(favouritesModel.userUid.uid);
      final advertRef = _firestore
          .collection(FirebaseCollections.adverts)
          .doc(favouritesModel.advertUid.uid);

      _talker.debug('📥 Fetching user document...');
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        _talker.error(
          '${ErrorMessages.userNotFound} ${favouritesModel.userUid.uid}',
        );
        return DataFailed(
          Exception(ErrorMessages.userNotFound),
          StackTrace.current,
        );
      }

      final userData = userDoc.data();
      if (userData == null) {
        _talker.error(
          '${ErrorMessages.userDataIsNullForUser} ${favouritesModel.userUid.uid}',
        );
        return DataFailed(
          Exception(ErrorMessages.userDataIsNull),
          StackTrace.current,
        );
      }

      final likes =
          (userData['likes'] as List<dynamic>? ?? [])
              .map((e) => e.toString())
              .toList();

      _talker.debug('📝 Toggling favourite status...');
      if (likes.contains(favouritesModel.advertUid.uid)) {
        likes.remove(favouritesModel.advertUid.uid);
        await advertRef.update({'likes': FieldValue.increment(-1)});
        _talker.debug('Removed from favourites');
      } else {
        likes.add(favouritesModel.advertUid.uid);
        await advertRef.update({'likes': FieldValue.increment(1)});
        _talker.debug('Added to favourites');
      }

      await userRef.update({'likes': likes});
      _talker.info('✅ Successfully toggled favourite status');
      return const DataSuccess(true);
    } on Exception catch (e, stack) {
      _talker.error(ErrorMessages.errorInToggleFavourite, e, stack);
      return DataFailed(Exception(e), stack);
    }
  }
}
