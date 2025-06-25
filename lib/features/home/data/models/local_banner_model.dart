import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:selo/features/home/data/models/home_model.dart';

part 'local_banner_model.g.dart';

@HiveType(typeId: 2)
class LocalBannerModel extends HiveObject {
  @HiveField(0)
  final String imageUrl;
  @HiveField(1)
  final String? title;
  @HiveField(2)
  final String? description;

  LocalBannerModel({required this.imageUrl, this.title, this.description});

  factory LocalBannerModel.fromBannerModel(BannerModel banner) {
    return LocalBannerModel(
      imageUrl: banner.imageUrl,
      title: banner.title,
      description: banner.description,
    );
  }

  BannerModel get banner =>
      BannerModel(imageUrl: imageUrl, title: title, description: description);
}
