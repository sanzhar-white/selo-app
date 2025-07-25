// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_advert_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalAdvertModelAdapter extends TypeAdapter<LocalAdvertModel> {
  @override
  final int typeId = 1;

  @override
  LocalAdvertModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalAdvertModel(
      advertJson: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalAdvertModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.advertJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalAdvertModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
