import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/data/datasources/home_interface.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/shared/models/advert_model.dart';
import 'package:talker_flutter/talker_flutter.dart';

class FirebaseHomeScreenRemoteDataSource
    implements HomeScreenRemoteDataSourceInterface {
  final FirebaseFirestore _firestore;
  final Talker _talker;
  DocumentSnapshot? lastDocument;

  FirebaseHomeScreenRemoteDataSource(this._firestore, this._talker);

  @override
  Future<DataState<List<String>>> getBanners() async {
    _talker.info('🔄 Fetching banners');
    try {
      final snapshot =
          await _firestore.collection(FirebaseCollections.banners).get();
      final banners =
          snapshot.docs
              .map((doc) => doc.data()['url'] as String?)
              .whereType<String>()
              .toList();
      _talker.info('✅ Successfully fetched ${banners.length} banners');
      return DataSuccess(banners);
    } catch (e, stackTrace) {
      _talker.error('❌ Failed to fetch banners', e, stackTrace);
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<List<AdvertModel>>> getAllAdvertisements(
    PaginationModel paginationModel,
  ) async {
    _talker.info(
      '🔄 Fetching all advertisements - Refresh: ${paginationModel.refresh}, Page: ${paginationModel.currentPage}',
    );

    try {
      if (paginationModel.refresh) {
        lastDocument = null;
        _talker.debug('🔄 Resetting pagination');
      }

      Query advertsRef = _firestore
          .collection(FirebaseCollections.adverts)
          .where('active', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(paginationModel.pageSize);

      if (lastDocument != null && paginationModel.currentPage > 1) {
        _talker.debug('📥 Using pagination with last document');
        advertsRef = advertsRef.startAfterDocument(lastDocument!);
      }

      final snapshot = await advertsRef.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        _talker.debug('📋 Retrieved ${snapshot.docs.length} advertisements');
      } else {
        _talker.debug('📋 No advertisements found');
      }

      final events = _parseDocuments(snapshot.docs);
      _talker.info('✅ Successfully fetched ${events.length} advertisements');
      return DataSuccess(events);
    } catch (e, stackTrace) {
      _talker.error('❌ Failed to fetch advertisements', e, stackTrace);
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<List<AdvertModel>>> getFilteredAdvertisements(
    SearchModel? searchModel,
    PaginationModel paginationModel,
  ) async {
    if (searchModel == null) {
      _talker.debug('🔄 No search model provided, fetching all advertisements');
      return getAllAdvertisements(paginationModel);
    }

    _talker.info(
      '🔄 Fetching filtered advertisements with params:\n'
      '🔍 Search: ${searchModel.searchQuery}\n'
      '📑 Category: ${searchModel.category}\n'
      '📍 District: ${searchModel.district}\n'
      '🌍 Region: ${searchModel.region}\n'
      '💰 Price: ${searchModel.priceFrom} - ${searchModel.priceTo}\n'
      '📊 Sort: ${searchModel.sortBy}',
    );

    try {
      final searchQuery = searchModel.searchQuery;
      final category = searchModel.category;
      final district = searchModel.district;
      final region = searchModel.region;
      final priceFrom = searchModel.priceFrom;
      final priceTo = searchModel.priceTo;
      final sortBy = searchModel.sortBy ?? 0;

      if (paginationModel.refresh) {
        lastDocument = null;
        _talker.debug('🔄 Resetting pagination');
      }

      Query advertsRef = _firestore
          .collection(FirebaseCollections.adverts)
          .where('active', isEqualTo: true);

      advertsRef = _applyFilters(
        advertsRef,
        category: category,
        district: district,
        region: region,
        priceFrom: priceFrom,
        priceTo: priceTo,
      );

      advertsRef = _applySort(advertsRef, sortBy);

      if (lastDocument != null && paginationModel.currentPage > 1) {
        _talker.debug('📥 Using pagination with last document');
        advertsRef = advertsRef.startAfterDocument(lastDocument!);
      }

      advertsRef = advertsRef.limit(paginationModel.pageSize);

      final snapshot = await advertsRef.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        _talker.debug('📋 Retrieved ${snapshot.docs.length} advertisements');
      } else {
        _talker.debug('📋 No advertisements found');
      }

      var result = _parseDocuments(snapshot.docs);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase().trim();
        result =
            result.where((element) {
              final title = element.title.toLowerCase();
              final description = element.description?.toLowerCase() ?? '';
              return title.contains(query) || description.contains(query);
            }).toList();
        _talker.debug(
          '🔍 Filtered to ${result.length} advertisements by search query',
        );
      }

      _talker.info(
        '✅ Successfully fetched ${result.length} filtered advertisements',
      );
      return DataSuccess(result);
    } catch (e, stackTrace) {
      _talker.error('❌ Failed to fetch filtered advertisements', e, stackTrace);
      if (e.toString().contains('failed-precondition')) {
        _talker.error(
          '❌ Firestore index required. Please create the index in the Firebase Console.',
        );
        return DataFailed(
          Exception(
            'Firestore index required. Please create the index in the Firebase Console.',
          ),
          stackTrace,
        );
      }
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<void>> viewAdvert(String advertUid) async {
    _talker.info('🔄 Incrementing view count for advert: $advertUid');
    try {
      await _firestore
          .collection(FirebaseCollections.adverts)
          .doc(advertUid)
          .update({'views': FieldValue.increment(1)});
      _talker.info('✅ Successfully incremented view count');
      return DataSuccess(null);
    } catch (e, stackTrace) {
      _talker.error('❌ Failed to increment view count', e, stackTrace);
      return DataFailed(Exception(e), stackTrace);
    }
  }

  List<AdvertModel> _parseDocuments(List<QueryDocumentSnapshot> docs) {
    final events = <AdvertModel>[];
    for (var doc in docs) {
      final data = doc.data();
      if (data is Map<String, dynamic>) {
        try {
          events.add(AdvertModel.fromMap(data));
        } catch (e, stackTrace) {
          _talker.error(
            '❌ Failed to parse advertisement: ${doc.id}',
            e,
            stackTrace,
          );
        }
      } else {
        _talker.error('❌ Invalid data type for advertisement: ${doc.id}');
      }
    }
    return events;
  }

  Query _applyFilters(
    Query query, {
    int? category,
    int? district,
    int? region,
    int? priceFrom,
    int? priceTo,
  }) {
    if (category != null && category! >= -1) {
      query = query.where('category', isEqualTo: category);
      _talker.debug('📑 Applied filter by category: $category');
    }
    if (district != null) {
      query = query.where('district', isEqualTo: district);
      _talker.debug('📍 Applied filter by district: $district');
    }
    if (region != null) {
      query = query.where('region', isEqualTo: region);
      _talker.debug('🌍 Applied filter by region: $region');
    }
    if (priceFrom != null) {
      query = query.where('price', isGreaterThanOrEqualTo: priceFrom);
      _talker.debug('💰 Applied filter by min price: $priceFrom');
    }
    if (priceTo != null) {
      query = query.where('price', isLessThanOrEqualTo: priceTo);
      _talker.debug('💰 Applied filter by max price: $priceTo');
    }
    return query;
  }

  Query _applySort(Query query, int sortBy) {
    switch (sortBy) {
      case 0: // По умолчанию (новые)
        query = query.orderBy('createdAt', descending: true);
        _talker.debug('📊 Applied default sorting (newest first)');
        break;
      case 1: // Сначала дешёвые
        query = query.orderBy('price');
        _talker.debug('📊 Applied sorting by price (ascending)');
        break;
      case 2: // Сначала дорогие
        query = query.orderBy('price', descending: true);
        _talker.debug('📊 Applied sorting by price (descending)');
        break;
      case 3: // Сначала новые
        query = query.orderBy('createdAt', descending: true);
        _talker.debug('📊 Applied sorting by creation date (newest first)');
        break;
      case 4: // Сначала старые
        query = query.orderBy('createdAt');
        _talker.debug('📊 Applied sorting by creation date (oldest first)');
        break;
      default:
        query = query.orderBy('createdAt', descending: true);
        _talker.debug('📊 Applied default sorting (newest first)');
    }
    return query;
  }
}
