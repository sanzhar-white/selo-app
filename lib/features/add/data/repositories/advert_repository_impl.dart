import 'package:selo/core/resources/data_state.dart';
import '../models/advert_model.dart';
import '../../domain/repositories/advert_repository.dart';

class AdvertRepositoryImpl extends AdvertRepository {
  @override
  Future<DataState<AdvertModel>> createAd() {
    // TODO: implement createAd
    throw UnimplementedError();
  }
}
