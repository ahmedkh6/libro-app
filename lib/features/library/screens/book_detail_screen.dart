import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/book.dart';
import '../providers/book_provider.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.book});
  final Book book;

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = book.readingProgress;
    final current = progress?.currentPage ?? 0;
    final total = book.totalPages ?? 1;
    final percent = (total > 0) ? (current / total) : 0.0;
    final percentString = (percent * 100).toStringAsFixed(0);
    final lastRead = progress?.lastReadAt;
    final fileSize = _formatFileSize(book.fileSize);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ─── Header with blurred background ───
            Stack(
              children: [
                // Background blur from cover
                SizedBox(
                  height: 340,
                  width: double.infinity,
                  child: book.coverPath != null
                      ? ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                          child: Image.file(File(book.coverPath!), fit: BoxFit.cover),
                        )
                      : Container(color: AppTheme.surfaceGray),
                ),
                // Dark overlay
                Container(
                  height: 340,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        AppTheme.background,
                      ],
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: 48,
                  left: 24,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
                    ),
                  ),
                ),
                // Cover image
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 160,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: book.coverPath != null
                            ? Image.file(File(book.coverPath!), fit: BoxFit.cover)
                            : Container(
                                color: AppTheme.surfaceGray,
                                child: const Center(child: Icon(Icons.auto_stories, size: 48, color: AppTheme.textMuted)),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ─── Book Title & Author ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    book.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Reading Progress Card ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border, width: 0.81),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Reading Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                        Text('$percentString%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.accent)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent.clamp(0.0, 1.0).toDouble(),
                        backgroundColor: AppTheme.surfaceGray,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Page $current of $total', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                        if (lastRead != null)
                          Text('Last read: ${_formatDate(lastRead)}', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── About Section ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  Text(
                    'A ${book.fileType.toUpperCase()} book by ${book.author}.',
                    style: const TextStyle(fontSize: 16, color: AppTheme.textTertiary, height: 1.6),
                  ),

                  const SizedBox(height: 24),

                  // ─── Metadata Grid (2x2) ───
                  Row(
                    children: [
                      _MetaItem(label: 'Format', value: book.fileType.toUpperCase(), icon: Icons.description_outlined),
                      const SizedBox(width: 16),
                      _MetaItem(label: 'Genre', value: 'General', icon: Icons.category_outlined),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MetaItem(label: 'Pages', value: '$total', icon: Icons.menu_book_outlined),
                      const SizedBox(width: 16),
                      _MetaItem(label: 'File Size', value: fileSize, icon: Icons.storage_outlined),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Edit / Delete Buttons ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push('/edit-book', extra: book);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimary,
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Book'),
                              content: const Text('Are you sure you want to delete this book?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: AppTheme.deleteRed))),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await ref.read(bookListProvider.notifier).deleteBook(book.id);
                            if (context.mounted) context.pop();
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.deleteRed,
                          side: const BorderSide(color: AppTheme.deleteRed),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Continue Reading CTA ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppTheme.orangeGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.ctaShadow,
                  ),
                  child: ElevatedButton(
                    onPressed: () => context.push('/reader', extra: book),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories, size: 20, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Continue Reading', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value, this.icon});
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 0.81),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Icon(icon, size: 18, color: AppTheme.accent),
            if (icon != null) const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
