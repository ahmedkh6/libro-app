import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/book_provider.dart';
import '../../../data/models/book.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final books = ref.watch(bookListProvider);

    final filteredBooks = _query.isEmpty
        ? books
        : books.where((b) =>
            b.title.toLowerCase().contains(_query.toLowerCase()) ||
            b.author.toLowerCase().contains(_query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search your library...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary.withOpacity(0.5)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: filteredBooks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          _query.isEmpty ? 'Start typing to search' : 'No books found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredBooks.length,
                    separatorBuilder: (_, __) => Divider(
                      color: theme.colorScheme.onSurface.withOpacity(0.06),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 68,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              book.fileType == 'pdf' ? Icons.picture_as_pdf : Icons.menu_book,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                              size: 24,
                            ),
                          ),
                        ),
                        title: Text(book.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text(book.author, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.fileType.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                          ),
                        ),
                        onTap: () {
                          if (book.fileType == 'pdf') {
                            context.push('/reader', extra: book);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
