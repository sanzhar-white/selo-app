import 'package:selo/core/resources/data_state.dart';
import '../../../../shared/models/advert_model.dart';

abstract class AdvertRepository {
  Future<DataState<AdvertModel>> createAd(AdvertModel advert);
}
