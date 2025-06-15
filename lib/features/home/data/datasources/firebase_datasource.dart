import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:selo/core/constants/firebase.dart';
import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/home/data/datasources/home_interface.dart';
import 'package:selo/features/home/data/models/home_model.dart';
import 'package:selo/shared/models/advert_model.dart';

class FirebaseHomeScreenRemoteDataSource
    implements HomeScreenRemoteDataSourceInterface {
  final FirebaseFirestore firestore;
  DocumentSnapshot? lastDocument;

  FirebaseHomeScreenRemoteDataSource({required this.firestore});

  @override
  Future<DataState<List<String>>> getBanners() async {
    try {
      final snapshot =
          await firestore.collection(FirebaseCollections.banners).get();
      final banners =
          snapshot.docs
              .map((doc) => doc.data()['url'] as String?)
              .whereType<String>()
              .toList();
      return DataSuccess(banners);
    } catch (e, stackTrace) {
      print('Failed to fetch banners $e $stackTrace');
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<List<AdvertModel>>> getAllAdvertisements(
    PaginationModel paginationModel,
  ) async {
    try {
      print(
        'Fetching all advertisements. Refresh: ${paginationModel.refresh}, Page: ${paginationModel.currentPage}',
      );

      if (paginationModel.refresh) {
        lastDocument = null;
      }

      Query advertsRef = firestore
          .collection(FirebaseCollections.adverts)
          .where('active', isEqualTo: true)
          .orderBy('createdAt', descending: true) // Добавьте сортировку
          .limit(paginationModel.pageSize);

      if (lastDocument != null && paginationModel.currentPage > 1) {
        advertsRef = advertsRef.startAfterDocument(lastDocument!);
      }

      final snapshot = await advertsRef.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      final events = _parseDocuments(snapshot.docs);
      return DataSuccess(events);
    } catch (e, stackTrace) {
      print('Failed to fetch advertisements $e $stackTrace');
      return DataFailed(Exception(e), stackTrace);
    }
  }

  @override
  Future<DataState<List<AdvertModel>>> getFilteredAdvertisements(
    SearchModel? searchModel,
    PaginationModel paginationModel,
  ) async {
    if (searchModel == null) {
      return getAllAdvertisements(paginationModel);
    }

    try {
      final searchQuery = searchModel.searchQuery;
      final category = searchModel.category;
      final district = searchModel.district;
      final region = searchModel.region;
      final priceFrom = searchModel.priceFrom;
      final priceTo = searchModel.priceTo;
      final sortBy = searchModel.sortBy ?? 0;

      print(
        'Fetching filtered advertisements with params: '
        'searchQuery: $searchQuery, category: $category, district: $district, '
        'region: $region, priceFrom: $priceFrom, priceTo: $priceTo, sortBy: $sortBy',
      );

      if (paginationModel.refresh) {
        lastDocument = null;
      }

      Query advertsRef = firestore
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
        advertsRef = advertsRef.startAfterDocument(lastDocument!);
      }

      advertsRef = advertsRef.limit(paginationModel.pageSize);

      final snapshot = await advertsRef.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
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
        print('Filtered ${result.length} advertisements by search query');
      }

      return DataSuccess(result);
    } catch (e, stackTrace) {
      print('Failed to fetch filtered advertisements $e $stackTrace');
      if (e.toString().contains('failed-precondition')) {
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
    try {
      await firestore
          .collection(FirebaseCollections.adverts)
          .doc(advertUid)
          .update({'views': FieldValue.increment(1)});
      return DataSuccess(null);
    } catch (e, stackTrace) {
      print('Failed to view advertisement $e $stackTrace');
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
          print('Failed to parse advertisement: ${doc.id} $e $stackTrace');
        }
      } else {
        print('Invalid data type for advertisement: ${doc.id}');
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
      print('Applied filter by category: $category');
    }
    if (district != null) {
      query = query.where('district', isEqualTo: district);
      print('Applied filter by district: $district');
    }
    if (region != null) {
      query = query.where('region', isEqualTo: region);
      print('Applied filter by region: $region');
    }
    if (priceFrom != null) {
      query = query.where('price', isGreaterThanOrEqualTo: priceFrom);
      print('Applied filter by min price: $priceFrom');
    }
    if (priceTo != null) {
      query = query.where('price', isLessThanOrEqualTo: priceTo);
      print('Applied filter by max price: $priceTo');
    }
    return query;
  }

  Query _applySort(Query query, int sortBy) {
    switch (sortBy) {
      case 0: // По умолчанию (новые)
        query = query.orderBy('createdAt', descending: true);
        print('Applied default sorting (newest first)');
        break;
      case 1: // Сначала дешёвые
        query = query.orderBy('price');
        print('Applied sorting by price (ascending)');
        break;
      case 2: // Сначала дорогие
        query = query.orderBy('price', descending: true);
        print('Applied sorting by price (descending)');
        break;
      case 3: // Сначала новые
        query = query.orderBy('createdAt', descending: true);
        print('Applied sorting by creation date (newest first)');
        break;
      case 4: // Сначала старые
        query = query.orderBy('createdAt');
        print('Applied sorting by creation date (oldest first)');
        break;
      default:
        query = query.orderBy('createdAt', descending: true);
        print('Applied default sorting (newest first)');
    }
    return query;
  }
}
