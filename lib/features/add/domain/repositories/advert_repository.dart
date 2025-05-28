import 'package:selo/core/resources/data_state.dart';
import '../entities/advert_entity.dart';

abstract class AdvertRepository {
  Future<DataState<AdvertEntity>> createAd(AdvertEntity advert);
}
