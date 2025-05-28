import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/models/category.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/features/add/data/datasources/categories_interface.dart';
import 'package:selo/features/add/data/models/advert_model.dart';

class FirebaseDatasource implements AdvertInteface, CategoriesInteface {
  final FirebaseFirestore _firestore;

  FirebaseDatasource(this._firestore);

  @override
  Future<DataState<AdvertModel>> createAd(AdvertModel advert) async {
    try {
      final ref = _firestore.collection(FirebaseCollections.adverts);
      final docRef = ref.doc();
      final newAdvert = advert.copyWith(
        uid: docRef.id,
        createdDate: Timestamp.now(),
        updatedDate: Timestamp.now(),
      );
      await docRef.set(newAdvert.toMap());
      return DataSuccess(newAdvert);
    } catch (e, st) {
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
