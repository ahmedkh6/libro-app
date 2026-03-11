import 'package:hive/hive.dart';

class Bookmark {
  final String text;
  final int page;
  final DateTime createdAt;

  Bookmark({
    required this.text,
    required this.page,
    required this.createdAt,
  });

  Bookmark copyWith({
    String? text,
    int? page,
    DateTime? createdAt,
  }) {
    return Bookmark(
      text: text ?? this.text,
      page: page ?? this.page,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class BookmarkAdapter extends TypeAdapter<Bookmark> {
  @override
  final int typeId = 3;

  @override
  Bookmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bookmark(
      text: fields[0] as String,
      page: fields[1] as int,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Bookmark obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.page)
      ..writeByte(2)
      ..write(obj.createdAt);
  }
}
