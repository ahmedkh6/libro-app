import 'package:hive/hive.dart';
import 'reading_progress.dart';
import 'bookmark.dart';

enum BookStatus { unread, reading, finished }

class Book {
  final String id; // Use UUID or unique path hash
  final String title;
  final String author;
  final String filePath; // Absolute or relative path within app documents
  final String? coverPath;
  final String fileType; // 'pdf' or 'epub'
  final int fileSize;
  final DateTime dateAdded;
  final BookStatus status;
  final int? totalPages;
  final ReadingProgress? readingProgress;
  final String? genre;
  final List<Bookmark>? bookmarks;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    this.coverPath,
    required this.fileType,
    required this.fileSize,
    required this.dateAdded,
    this.status = BookStatus.unread,
    this.totalPages,
    this.readingProgress,
    this.genre,
    this.bookmarks,
  });

  Book copyWith({
    String? title,
    String? author,
    String? coverPath,
    BookStatus? status,
    int? totalPages,
    ReadingProgress? readingProgress,
    String? genre,
    List<Bookmark>? bookmarks,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      filePath: filePath,
      coverPath: coverPath ?? this.coverPath,
      fileType: fileType,
      fileSize: fileSize,
      dateAdded: dateAdded,
      status: status ?? this.status,
      totalPages: totalPages ?? this.totalPages,
      readingProgress: readingProgress ?? this.readingProgress,
      genre: genre ?? this.genre,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }
}

class BookStatusAdapter extends TypeAdapter<BookStatus> {
  @override
  final int typeId = 2;

  @override
  BookStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BookStatus.unread;
      case 1:
        return BookStatus.reading;
      case 2:
        return BookStatus.finished;
      default:
        return BookStatus.unread;
    }
  }

  @override
  void write(BinaryWriter writer, BookStatus obj) {
    switch (obj) {
      case BookStatus.unread:
        writer.writeByte(0);
        break;
      case BookStatus.reading:
        writer.writeByte(1);
        break;
      case BookStatus.finished:
        writer.writeByte(2);
        break;
    }
  }
}

class BookAdapter extends TypeAdapter<Book> {
  @override
  final int typeId = 0;

  @override
  Book read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Book(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      filePath: fields[3] as String,
      coverPath: fields[4] as String?,
      fileType: fields[5] as String,
      fileSize: fields[6] as int,
      dateAdded: fields[7] as DateTime,
      status: fields[8] as BookStatus? ?? BookStatus.unread,
      totalPages: fields[9] as int?,
      readingProgress: fields[10] as ReadingProgress?,
      genre: fields[11] as String?,
      bookmarks: (fields[12] as List?)?.cast<Bookmark>(),
    );
  }

  @override
  void write(BinaryWriter writer, Book obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.coverPath)
      ..writeByte(5)
      ..write(obj.fileType)
      ..writeByte(6)
      ..write(obj.fileSize)
      ..writeByte(7)
      ..write(obj.dateAdded)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.totalPages)
      ..writeByte(10)
      ..write(obj.readingProgress)
      ..writeByte(11)
      ..write(obj.genre)
      ..writeByte(12)
      ..write(obj.bookmarks);
  }
}
