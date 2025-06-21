import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/core/constants/error_message.dart';
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

  /// Для поддержки независимой пагинации по разным фильтрам
  final Map<String, DocumentSnapshot?> _lastDocuments = {};

  FirebaseHomeScreenRemoteDataSource(this._firestore, this._talker);

  /// Генерирует уникальный ключ для фильтрации и пагинации
  String _filterKey({
    int? category,
    int? district,
    int? region,
    int? priceFrom,
    int? priceTo,
    int? sortBy,
    int? page,
    bool? refresh,
    String? searchQuery,
  }) {
    return [
      'cat:${category ?? ''}',
      'dist:${district ?? ''}',
      'reg:${region ?? ''}',
      'pf:${priceFrom ?? ''}',
      'pt:${priceTo ?? ''}',
      'sort:${sortBy ?? ''}',
      'page:${page ?? ''}',
      'refresh:${refresh ?? false}',
      'q:${searchQuery ?? ''}',
    ].join('|');
  }

  @override
  /// Получает список баннеров
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
      _talker.error(ErrorMessages.failedToFetchBanners, e, stackTrace);
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  /// Получает список объявлений с пагинацией
  Future<DataState<List<AdvertModel>>> getAllAdvertisements(
    PaginationModel paginationModel,
  ) async {
    _talker.info(
      '🔄 Fetching all advertisements - Refresh: ${paginationModel.refresh}, Page: ${paginationModel.currentPage}',
    );
    final filterKey = _filterKey(
      page: paginationModel.currentPage,
      refresh: paginationModel.refresh,
    );

    try {
      if (paginationModel.refresh) {
        _lastDocuments[filterKey] = null;
        _talker.debug('🔄 Resetting pagination for key: $filterKey');
      }

      Query advertsRef = _firestore
          .collection(FirebaseCollections.adverts)
          .where('active', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(paginationModel.pageSize);

      final lastDoc = _lastDocuments[filterKey];
      if (lastDoc != null && paginationModel.currentPage > 1) {
        _talker.debug(
          '📥 Using pagination with last document for key: $filterKey',
        );
        advertsRef = advertsRef.startAfterDocument(lastDoc);
      }

      final snapshot = await advertsRef.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocuments[filterKey] = snapshot.docs.last;
        _talker.debug('📋 Retrieved ${snapshot.docs.length} advertisements');
      } else {
        _talker.debug('📋 No advertisements found');
      }

      final events = _parseDocuments(snapshot.docs);
      _talker.info('✅ Successfully fetched ${events.length} advertisements');
      return DataSuccess(events);
    } catch (e, stackTrace) {
      _talker.error(ErrorMessages.failedToFetchAdvertisements, e, stackTrace);
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  /// Получает отфильтрованные объявления с пагинацией
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
    final filterKey = _filterKey(
      category: searchModel.category,
      district: searchModel.district,
      region: searchModel.region,
      priceFrom: searchModel.priceFrom,
      priceTo: searchModel.priceTo,
      sortBy: searchModel.sortBy,
      page: paginationModel.currentPage,
      refresh: paginationModel.refresh,
      searchQuery: searchModel.searchQuery,
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
        _lastDocuments[filterKey] = null;
        _talker.debug('🔄 Resetting pagination for key: $filterKey');
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

      final lastDoc = _lastDocuments[filterKey];
      if (lastDoc != null && paginationModel.currentPage > 1) {
        _talker.debug(
          '📥 Using pagination with last document for key: $filterKey',
        );
        advertsRef = advertsRef.startAfterDocument(lastDoc);
      }

      advertsRef = advertsRef.limit(paginationModel.pageSize);

      final snapshot = await advertsRef.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocuments[filterKey] = snapshot.docs.last;
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
      _talker.error(
        ErrorMessages.failedToFetchFilteredAdvertisements,
        e,
        stackTrace,
      );
      if (e.toString().contains('failed-precondition')) {
        _talker.error('${ErrorMessages.firestoreIndexRequired}');
        return DataFailed(
          Exception(ErrorMessages.firestoreIndexRequired),
          stackTrace,
        );
      }
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  /// Инкрементирует просмотры объявления
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
      _talker.error(ErrorMessages.failedToIncrementViewCount, e, stackTrace);
      return DataFailed(Exception(e), stackTrace);
    }
  }

  /// Парсит документы Firestore в AdvertModel, логирует ошибки парсинга
  List<AdvertModel> _parseDocuments(List<QueryDocumentSnapshot> docs) {
    final events = <AdvertModel>[];
    final errors = <String>[];
    for (var doc in docs) {
      final data = doc.data();
      if (data is Map<String, dynamic>) {
        try {
          events.add(AdvertModel.fromMap(data));
        } catch (e, stackTrace) {
          final msg = '${ErrorMessages.failedToParseAdvertisement}: ${doc.id}';
          _talker.error(msg, e, stackTrace);
          errors.add(msg);
        }
      } else {
        final msg =
            '${ErrorMessages.invalidDataTypeForAdvertisement} ${doc.id}';
        _talker.error(msg);
        errors.add(msg);
      }
    }
    if (errors.isNotEmpty) {
      _talker.warning('⚠️ Parse errors: ${errors.length}');
    }
    return events;
  }

  /// Применяет фильтры к Firestore-запросу
  Query _applyFilters(
    Query query, {
    int? category,
    int? district,
    int? region,
    int? priceFrom,
    int? priceTo,
  }) {
    if (category != null && category >= -1) {
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
    if (priceFrom != null && priceFrom >= 0) {
      query = query.where('price', isGreaterThanOrEqualTo: priceFrom);
      _talker.debug('💰 Applied filter by min price: $priceFrom');
    }
    if (priceTo != null && priceTo >= 0) {
      query = query.where('price', isLessThanOrEqualTo: priceTo);
      _talker.debug('💰 Applied filter by max price: $priceTo');
    }
    return query;
  }

  /// Применяет сортировку к Firestore-запросу
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
        final msg = 'Unknown sortBy: $sortBy';
        _talker.error(msg);
        throw ArgumentError(msg);
    }
    return query;
  }
}
