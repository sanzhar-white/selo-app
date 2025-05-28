import 'package:selo/core/resources/data_state.dart';
import 'package:selo/features/add/data/datasources/advert_interface.dart';
import 'package:selo/features/add/domain/entities/advert_entity.dart';
import '../models/advert_model.dart';
import '../../domain/repositories/advert_repository.dart';

class AdvertRepositoryImpl extends AdvertRepository implements AdvertInteface {
  final AdvertInteface _advertInteface;

  AdvertRepositoryImpl(this._advertInteface);

  @override
  Future<DataState<AdvertModel>> createAd(AdvertEntity advert) {
    return _advertInteface.createAd(advert as AdvertModel);
  }
}
