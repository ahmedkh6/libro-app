import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../library/providers/book_provider.dart';
import '../../../data/models/book.dart';
import '../../../data/models/bookmark.dart';
import '../../../data/models/reading_progress.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsyncValue = ref.watch(bookListProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceGray,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back, size: 20, color: AppTheme.textPrimary),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Bookmarks',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
            ),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGray,
                  borderRadius: BorderRadius.circular(9999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 20, color: AppTheme.textSecondary),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search snippets or notes',
                          hintStyle: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Divider
            const Divider(height: 1, thickness: 1, color: AppTheme.border),
            
            // Content
            Expanded(
              child: Builder(
                builder: (context) {
                  final booksWithBookmarks = booksAsyncValue.where((b) => b.bookmarks != null && b.bookmarks!.isNotEmpty).toList();

                  if (booksWithBookmarks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceGray,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(Icons.bookmark_border, size: 40, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No bookmarks yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your bookmarks will be found here',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: booksWithBookmarks.length,
                    itemBuilder: (context, index) {
                      final book = booksWithBookmarks[index];
                      // Sort bookmarks by newest first
                      final sortedBookmarks = List<Bookmark>.from(book.bookmarks!)
                        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Book Header
                            Row(
                              children: [
                                // Thumbnail
                                Container(
                                  width: 40,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: book.coverPath != null
                                        ? Image.file(File(book.coverPath!), fit: BoxFit.cover)
                                        : Container(
                                            color: AppTheme.surfaceGray,
                                            child: Center(
                                              child: Text(book.title.substring(0, 1).toUpperCase(),
                                                style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.textMuted)),
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        book.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          height: 1.25,
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book.author.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.6,
                                          height: 1.33,
                                          color: AppTheme.textMuted,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Bookmarks List
                            ...sortedBookmarks.map((bookmark) {
                              final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                              final dateStr = '${months[bookmark.createdAt.month - 1]} ${bookmark.createdAt.day}, ${bookmark.createdAt.year}';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0x0D1024D4), width: 1),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x0D000000),
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Highlight Container (Orange left border)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accent.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Container(
                                              width: 3,
                                              decoration: const BoxDecoration(
                                                color: AppTheme.accent,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8),
                                                  bottomLeft: Radius.circular(8),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(12),
                                                child: Text(
                                                  '"${bookmark.text}"',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF1E293B), // slate-800 equivalent
                                                    height: 1.625, // ≈ 24.38px
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    
                                    // Footer with Metedata & Button
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Added $dateStr • Page ${bookmark.page}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF3A3A3A),
                                              fontWeight: FontWeight.w400,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            final updatedProgress = book.readingProgress?.copyWith(currentPage: bookmark.page) ?? 
                                                ReadingProgress(currentPage: bookmark.page, progressPercent: book.totalPages != null && book.totalPages! > 0 ? bookmark.page / book.totalPages! : 0.0, lastReadAt: DateTime.now());
                                            
                                            final updatedBook = book.copyWith(readingProgress: updatedProgress);
                                            ref.read(bookListProvider.notifier).updateBook(updatedBook);
                                            context.push('/reader', extra: updatedBook);
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.open_in_new, size: 12, color: AppTheme.accent),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Go to page',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.accent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
