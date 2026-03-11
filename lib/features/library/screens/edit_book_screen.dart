import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../../core/theme/app_theme.dart';
import '../../../data/models/book.dart';
import '../providers/book_provider.dart';

class EditBookScreen extends ConsumerStatefulWidget {
  const EditBookScreen({super.key, required this.book});
  final Book book;

  @override
  ConsumerState<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends ConsumerState<EditBookScreen> {
  bool _isLoading = false;
  String? _coverPath;
  
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _pagesController;
  String _selectedGenre = 'General';
  final List<String> _genres = ['General', 'Classic', 'Sci-Fi', 'Thriller', 'Biography', 'Self-Help', 'Fantasy', 'Mystery', 'Romance', 'Non-Fiction'];

  @override
  void initState() {
    super.initState();
    _coverPath = widget.book.coverPath;
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _pagesController = TextEditingController(text: widget.book.totalPages?.toString() ?? '');
    _selectedGenre = widget.book.genre ?? 'General';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final appDocsDir = await getApplicationDocumentsDirectory();
      final librosDir = Directory(p.join(appDocsDir.path, 'libro_books'));
      if (!await librosDir.exists()) {
        await librosDir.create(recursive: true);
      }
      
      final tempId = DateTime.now().microsecondsSinceEpoch.toString();
      final extension = p.extension(pickedFile.path).isNotEmpty ? p.extension(pickedFile.path) : '.jpg';
      final newCoverFile = File(p.join(librosDir.path, '${tempId}_cover$extension'));
      final savedImage = await File(pickedFile.path).copy(newCoverFile.path);
      
      setState(() {
        _coverPath = savedImage.path;
      });
    }
  }

  Future<void> _updateBook() async {
    setState(() => _isLoading = true);
    try {
      final updatedBook = widget.book.copyWith(
        title: _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
        author: _authorController.text.isEmpty ? 'Unknown Author' : _authorController.text,
        coverPath: _coverPath,
        totalPages: int.tryParse(_pagesController.text) ?? widget.book.totalPages,
        genre: _selectedGenre,
      );

      await ref.read(bookListProvider.notifier).updateBook(updatedBook);

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating book: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
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
                      child: const Icon(Icons.arrow_back, size: 20, color: AppTheme.textPrimary),
                    ),
                  ),
                  const Expanded(
                    child: Text('Edit Book', textAlign: TextAlign.center, style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                    )),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ─── Content ───
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Book Details', style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                    )),
                    const SizedBox(height: 24),

                    // Cover Preview
                    Center(
                      child: GestureDetector(
                        onTap: _pickCoverImage,
                        child: Column(
                          children: [
                            Container(
                              width: 200,
                              height: 280,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: AppTheme.heroShadow,
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: _coverPath != null
                                          ? Image.file(File(_coverPath!), fit: BoxFit.cover)
                                          : Container(
                                              color: AppTheme.surfaceGray,
                                              child: const Center(child: Icon(Icons.auto_stories, size: 48, color: AppTheme.textMuted)),
                                            ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.camera_alt, color: Colors.white, size: 36),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Edit Cover', style: TextStyle(fontSize: 14, color: AppTheme.accent)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title field
                    const Text('Title', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(hintText: 'Enter book title'),
                    ),

                    const SizedBox(height: 20),

                    // Author field
                    const Text('Author', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _authorController,
                      style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(hintText: 'Enter author name'),
                    ),

                    const SizedBox(height: 20),

                    // Genre dropdown
                    const Text('Genre', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGenre,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                          items: _genres.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          onChanged: (v) => setState(() => _selectedGenre = v ?? 'General'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Total Pages
                    const Text('Total Pages', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _pagesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(hintText: 'Number of pages'),
                    ),

                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _updateBook,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accent,
                                foregroundColor: Colors.white,
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Confirm'),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
