import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/book.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  static const String _booksBoxName = 'books_box';
  Box<Book>? _booksBox;

  Future<Box<Book>> _getBox() async {
    if (_booksBox == null || !_booksBox!.isOpen) {
      _booksBox = await Hive.openBox<Book>(_booksBoxName);
    }
    return _booksBox!;
  }

  Future<void> init() async {
    _booksBox = await Hive.openBox<Book>(_booksBoxName);
  }

  List<Book> getAllBooks() {
    if (Hive.isBoxOpen(_booksBoxName)) {
      final box = Hive.box<Book>(_booksBoxName);
      return box.values.toList().cast<Book>();
    }
    return [];
  }

  Future<List<Book>> getAllBooksAsync() async {
    final box = await _getBox();
    return box.values.toList().cast<Book>();
  }

  Book? getBookById(String id) {
    return _booksBox?.get(id);
  }

  Future<void> saveBook(Book book) async {
    final box = await _getBox();
    await box.put(book.id, book);
  }

  Future<void> deleteBook(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
