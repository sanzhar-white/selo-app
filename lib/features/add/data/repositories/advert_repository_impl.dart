import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/shared/models/advert_model.dart';
import '../../domain/repositories/advert_repository.dart';

class AdvertRepositoryImpl extends AdvertRepository implements AdvertInteface {
  final AdvertInteface _advertInteface;

  AdvertRepositoryImpl(this._advertInteface);

  @override
  Future<DataState<AdvertModel>> createAd(AdvertModel advert) {
    return _advertInteface.createAd(advert);
  }
}
