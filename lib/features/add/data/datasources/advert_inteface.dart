import 'package:selo/core/resources/data_state.dart';

import '../models/advert_model.dart';

abstract class AdvertInteface {
  Future<DataState<AdvertModel>> createAd();
}
