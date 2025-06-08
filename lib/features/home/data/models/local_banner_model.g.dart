// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_banner_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalBannerModelAdapter extends TypeAdapter<LocalBannerModel> {
  @override
  final int typeId = 2;

  @override
  LocalBannerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalBannerModel(
      imageUrl: fields[0] as String,
      title: fields[1] as String?,
      description: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LocalBannerModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.imageUrl)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalBannerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
