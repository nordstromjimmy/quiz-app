// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 2;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      xp: fields[0] as int,
      level: fields[1] as int,
      quizzesTaken: fields[2] as int,
      quizzesCompleted: fields[3] as int,
      totalCorrectAnswers: fields[4] as int,
      totalQuestionsAnswered: fields[5] as int,
      perfectQuizzes: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.xp)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.quizzesTaken)
      ..writeByte(3)
      ..write(obj.quizzesCompleted)
      ..writeByte(4)
      ..write(obj.totalCorrectAnswers)
      ..writeByte(5)
      ..write(obj.totalQuestionsAnswered)
      ..writeByte(6)
      ..write(obj.perfectQuizzes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
