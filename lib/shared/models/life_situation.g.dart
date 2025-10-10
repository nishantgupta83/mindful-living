// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_situation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LifeSituationAdapter extends TypeAdapter<LifeSituation> {
  @override
  final int typeId = 0;

  @override
  LifeSituation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LifeSituation(
      id: fields[0] as String?,
      title: fields[1] as String,
      description: fields[2] as String,
      mindfulApproach: fields[3] as String,
      practicalSteps: fields[4] as String,
      keyInsights: fields[5] as String,
      lifeArea: fields[6] as String,
      tags: (fields[7] as List).cast<String>(),
      difficultyLevel: fields[8] as int,
      estimatedReadTime: fields[9] as int,
      wellnessFocus: fields[10] as String,
      voiceKeywords: (fields[11] as List?)?.cast<String>(),
      synonyms: (fields[12] as List?)?.cast<String>(),
      spokenTitle: fields[13] as String?,
      spokenActionSteps: fields[14] as String?,
      voicePopularity: fields[15] as int?,
      audioResponseUrl: fields[16] as String?,
      createdAt: fields[17] as DateTime?,
      updatedAt: fields[18] as DateTime?,
      isVoiceOptimized: fields[19] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, LifeSituation obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.mindfulApproach)
      ..writeByte(4)
      ..write(obj.practicalSteps)
      ..writeByte(5)
      ..write(obj.keyInsights)
      ..writeByte(6)
      ..write(obj.lifeArea)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.difficultyLevel)
      ..writeByte(9)
      ..write(obj.estimatedReadTime)
      ..writeByte(10)
      ..write(obj.wellnessFocus)
      ..writeByte(11)
      ..write(obj.voiceKeywords)
      ..writeByte(12)
      ..write(obj.synonyms)
      ..writeByte(13)
      ..write(obj.spokenTitle)
      ..writeByte(14)
      ..write(obj.spokenActionSteps)
      ..writeByte(15)
      ..write(obj.voicePopularity)
      ..writeByte(16)
      ..write(obj.audioResponseUrl)
      ..writeByte(17)
      ..write(obj.createdAt)
      ..writeByte(18)
      ..write(obj.updatedAt)
      ..writeByte(19)
      ..write(obj.isVoiceOptimized);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LifeSituationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
