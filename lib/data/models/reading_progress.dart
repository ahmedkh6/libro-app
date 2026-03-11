import 'package:hive/hive.dart';

class ReadingProgress {
  final int? currentPage;
  final String? currentCfi;
  final double progressPercent;
  final DateTime lastReadAt;

  ReadingProgress({
    this.currentPage,
    this.currentCfi,
    this.progressPercent = 0.0,
    required this.lastReadAt,
  });

  ReadingProgress copyWith({
    int? currentPage,
    String? currentCfi,
    double? progressPercent,
    DateTime? lastReadAt,
  }) {
    return ReadingProgress(
      currentPage: currentPage ?? this.currentPage,
      currentCfi: currentCfi ?? this.currentCfi,
      progressPercent: progressPercent ?? this.progressPercent,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }
}

class ReadingProgressAdapter extends TypeAdapter<ReadingProgress> {
  @override
  final int typeId = 1;

  @override
  ReadingProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReadingProgress(
      currentPage: fields[0] as int?,
      currentCfi: fields[1] as String?,
      progressPercent: fields[2] as double? ?? 0.0,
      lastReadAt: fields[3] as DateTime? ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, ReadingProgress obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currentPage)
      ..writeByte(1)
      ..write(obj.currentCfi)
      ..writeByte(2)
      ..write(obj.progressPercent)
      ..writeByte(3)
      ..write(obj.lastReadAt);
  }
}
