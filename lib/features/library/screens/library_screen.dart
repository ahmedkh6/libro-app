import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/book_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../data/models/book.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> with TickerProviderStateMixin {
  String _selectedGenre = 'All';
  final List<String> _genres = ['All', 'General', 'Classic', 'Sci-Fi', 'Thriller', 'Biography', 'Self-Help', 'Fantasy', 'Mystery', 'Romance', 'Non-Fiction'];

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(bookListProvider);
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;
    final String? avatarUrl = user?.photoURL;

    // Filter books with reading progress
    final booksInProgress = books.where((b) {
      final progress = b.readingProgress;
      if (progress == null) return false;
      final total = b.totalPages ?? 0;
      if (total == 0) return false;
      final percent = (progress.currentPage ?? 0) / total;
      return percent > 0 && percent < 1.0;
    }).toList();

    // Filter by genre
    final filteredBooks = _selectedGenre == 'All'
        ? books
        : books.where((b) => b.genre == _selectedGenre).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Top Bar ───
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Library', style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    )),
                    Row(
                      children: [
                        // Search Button
                        GestureDetector(
                          onTap: () => context.push('/search'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppTheme.surfaceGray,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.search, size: 20, color: AppTheme.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Avatar
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.border, width: 1.62),
                            ),
                            child: ClipOval(
                              child: avatarUrl != null
                                  ? Image.network(avatarUrl, fit: BoxFit.cover)
                                  : const Icon(Icons.person, size: 20, color: AppTheme.textMuted),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── Genre Filter Chips ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: _genres.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final genre = _genres[index];
                    final isSelected = genre == _selectedGenre;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGenre = genre),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.textPrimary : AppTheme.surfaceGray,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Center(
                          child: Text(
                            genre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? Colors.white : AppTheme.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          if (books.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(context, ref),
            )
          else ...[
            // ─── Continue Reading Section ───
            if (booksInProgress.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 20, color: AppTheme.textPrimary),
                      const SizedBox(width: 8),
                      Text('Continue Reading', style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      )),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = booksInProgress[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: _ContinueReadingCard(book: book),
                    );
                  },
                  childCount: booksInProgress.length,
                ),
              ),
            ],

            // ─── All Books Grid ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All Books', style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    )),
                    const SizedBox(height: 4),
                    Text('${filteredBooks.length} books', style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    )),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final book = filteredBooks[index];
                    return _BookGridCard(
                      book: book,
                      onTap: () => context.push('/book-detail', extra: book),
                      onLongPress: () => _showDeleteSheet(context, book),
                    );
                  },
                  childCount: filteredBooks.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteSheet(BuildContext context, Book book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(
                color: AppTheme.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              )),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                leading: const Icon(Icons.delete_outline, color: AppTheme.deleteRed),
                title: const Text('Remove from Library', style: TextStyle(color: AppTheme.deleteRed, fontWeight: FontWeight.w500)),
                onTap: () {
                  ctx.pop();
                  ref.read(bookListProvider.notifier).deleteBook(book.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: AppTheme.orangeGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_stories, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Text('Your Personal Library', textAlign: TextAlign.center, style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            )),
            const SizedBox(height: 12),
            Text(
              'Import a PDF or EPUB to begin building your collection.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => ref.read(bookListProvider.notifier).importBook(),
                child: const Text('Import Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Continue Reading Card ───
class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.book});
  final Book book;

  @override
  Widget build(BuildContext context) {
    final progress = book.readingProgress;
    final current = progress?.currentPage ?? 0;
    final total = book.totalPages ?? 1;
    final percent = (total > 0) ? (current / total) : 0.0;
    final percentString = (percent * 100).toStringAsFixed(0);

    return GestureDetector(
      onTap: () {
        if (book.fileType == 'pdf') {
          context.push('/reader', extra: book);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border, width: 0.81),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            // Book Thumbnail
            Container(
              width: 64,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: book.coverPath != null
                    ? Image.file(File(book.coverPath!), fit: BoxFit.cover)
                    : Container(
                        color: AppTheme.surfaceGray,
                        child: Center(child: Text(book.title.substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textMuted))),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(book.author, style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary,
                  ), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  // Progress info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Page $current of $total', style: const TextStyle(
                        fontSize: 14, color: AppTheme.textSecondary,
                      )),
                      Text('$percentString%', style: const TextStyle(
                        fontSize: 14, color: AppTheme.accent,
                      )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: AppTheme.progressTrack,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.progressFill),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Book Grid Card ───
class _BookGridCard extends StatefulWidget {
  const _BookGridCard({required this.book, required this.onTap, required this.onLongPress});
  final Book book;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_BookGridCard> createState() => _BookGridCardState();
}

class _BookGridCardState extends State<_BookGridCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final progress = book.readingProgress;
    final current = progress?.currentPage ?? 0;
    final total = book.totalPages ?? 0;
    final percent = (total > 0) ? (current / total) : 0.0;
    final percentString = (percent * 100).toStringAsFixed(0);
    final isNew = progress == null || (percent == 0);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 0.81),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover Image
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: book.coverPath != null
                          ? Image.file(File(book.coverPath!), fit: BoxFit.cover)
                          : Container(
                              color: AppTheme.surfaceGray,
                              child: Center(child: Text(book.title.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w500, color: AppTheme.textMuted))),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Title
                Text(book.title, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                // Author
                Text(book.author, style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary,
                ), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                // Progress or New badge
                if (isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.newBadgeBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('New', style: TextStyle(
                      fontSize: 12, color: AppTheme.newBadgeText,
                    )),
                  )
                else if (percent > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      backgroundColor: AppTheme.progressTrack,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.progressFill),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$percentString% complete', style: const TextStyle(
                    fontSize: 12, color: AppTheme.accent,
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
