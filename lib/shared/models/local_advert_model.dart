import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:selo/shared/models/advert_model.dart';

part 'local_advert_model.g.dart';

@HiveType(typeId: 1)
class LocalAdvertModel extends HiveObject {
  @HiveField(0)
  final String advertJson; // Сохраняем UserModel как json-строку

  LocalAdvertModel({required this.advertJson});

  factory LocalAdvertModel.fromAdvertModel(AdvertModel advert) {
    return LocalAdvertModel(advertJson: json.encode(advert.toHiveMap()));
  }

  AdvertModel get advert => AdvertModel.fromHiveMap(json.decode(advertJson));
}
