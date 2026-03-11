import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdfx/pdfx.dart' as pdfx;

import '../../../data/database/database_service.dart';
import '../../../data/models/book.dart';

final bookListProvider = NotifierProvider<BookListNotifier, List<Book>>(BookListNotifier.new);

class BookListNotifier extends Notifier<List<Book>> {
  @override
  List<Book> build() {
    // Schedule an async refresh immediately after build to
    // ensure Hive database is read correctly if it missed the sync window.
    Future.microtask(() => refresh());
    return ref.read(databaseServiceProvider).getAllBooks();
  }

  Future<void> refresh() async {
    final books = await ref.read(databaseServiceProvider).getAllBooksAsync();
    state = books;
  }

  Future<void> importBook() async {
    try {
      debugPrint('[Libro] Starting file picker...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
      );

      if (result == null) {
        debugPrint('[Libro] File picker cancelled by user.');
        return;
      }

      if (result.files.single.path == null) {
        debugPrint('[Libro] File picker returned null path.');
        return;
      }

      final filePath = result.files.single.path!;
      debugPrint('[Libro] File picked: $filePath');

      final originalFile = File(filePath);
      final extension = p.extension(originalFile.path).replaceAll('.', '').toLowerCase();
      final fileName = p.basenameWithoutExtension(originalFile.path);

      debugPrint('[Libro] Extension: $extension, Name: $fileName');

      // Copy to app documents directory
      final appDocsDir = await getApplicationDocumentsDirectory();
      final librosDir = Directory(p.join(appDocsDir.path, 'libro_books'));
      if (!await librosDir.exists()) {
        await librosDir.create(recursive: true);
      }

      final newId = DateTime.now().microsecondsSinceEpoch.toString();
      final newPath = p.join(librosDir.path, '$newId.$extension');
      debugPrint('[Libro] Copying to: $newPath');

      await originalFile.copy(newPath);
      debugPrint('[Libro] File copied successfully.');

      String? coverPath;
      if (extension == 'pdf') {
        try {
          debugPrint('[Libro] Generating thumbnail for PDF...');
          final document = await pdfx.PdfDocument.openFile(newPath);
          final page = await document.getPage(1);
          final pageImage = await page.render(
            width: page.width,
            height: page.height,
            format: pdfx.PdfPageImageFormat.jpeg,
          );
          if (pageImage != null) {
            final coverFile = File(p.join(librosDir.path, '${newId}_cover.jpg'));
            await coverFile.writeAsBytes(pageImage.bytes);
            coverPath = coverFile.path;
            debugPrint('[Libro] Thumbnail saved at $coverPath');
          }
          await page.close();
          await document.close();
        } catch (e) {
          debugPrint('[Libro] Failed to generate thumbnail: $e');
        }
      }

      // Create book model
      final newBook = Book(
        id: newId,
        title: fileName,
        author: 'Unknown Author',
        filePath: newPath,
        coverPath: coverPath,
        fileType: extension,
        fileSize: await originalFile.length(),
        dateAdded: DateTime.now(),
      );

      // Save to DB
      debugPrint('[Libro] Saving to database...');
      await ref.read(databaseServiceProvider).saveBook(newBook);
      debugPrint('[Libro] Book saved to DB!');

      // Refresh state
      await refresh();
      debugPrint('[Libro] State refreshed. Total books: ${state.length}');
    } catch (e, st) {
      debugPrint('[Libro] ERROR importing book: $e');
      debugPrint('[Libro] Stack trace: $st');
    }
  }

  Future<void> updateBook(Book updatedBook) async {
    await ref.read(databaseServiceProvider).saveBook(updatedBook);
    await refresh();
  }

  Future<void> deleteBook(String id) async {
    final book = state.firstWhere((b) => b.id == id);
    final file = File(book.filePath);
    if (await file.exists()) {
      await file.delete();
    }
    await ref.read(databaseServiceProvider).deleteBook(id);
    await refresh();
  }
}
