import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/advert_inteface.dart';
import 'package:selo/features/add/data/models/advert_model.dart';

class FirebaseDatasource implements AdvertInteface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Future<DataState<AdvertModel>> createAd() async {
    try {} catch (e, st) {}
  }
}
