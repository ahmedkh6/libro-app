import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdfx/pdfx.dart' as pdfx;
import '../../../core/theme/app_theme.dart';
import '../../../data/database/database_service.dart';
import '../../../data/models/book.dart';
import '../providers/book_provider.dart';

class ImportBookScreen extends ConsumerStatefulWidget {
  const ImportBookScreen({super.key});

  @override
  ConsumerState<ImportBookScreen> createState() => _ImportBookScreenState();
}

class _ImportBookScreenState extends ConsumerState<ImportBookScreen> {
  int _currentStep = 0; // 0 = file select, 1 = book details
  bool _isLoading = false;
  String? _pickedFilePath;
  String? _coverPath;
  String _fileExtension = '';
  int _fileSize = 0;
  int _totalPages = 0;

  final _titleController = TextEditingController();
  final _authorController = TextEditingController(text: 'Unknown Author');
  final _pagesController = TextEditingController();
  String _selectedGenre = 'General';
  final List<String> _genres = ['General', 'Classic', 'Sci-Fi', 'Thriller', 'Biography', 'Self-Help', 'Fantasy', 'Mystery', 'Romance', 'Non-Fiction'];

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

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
      );
      if (result == null || result.files.single.path == null) {
        setState(() => _isLoading = false);
        return;
      }
      final filePath = result.files.single.path!;
      final originalFile = File(filePath);
      final extension = p.extension(originalFile.path).replaceAll('.', '').toLowerCase();
      final fileName = p.basenameWithoutExtension(originalFile.path);

      _pickedFilePath = filePath;
      _fileExtension = extension;
      _fileSize = await originalFile.length();
      _titleController.text = fileName;

      // Generate cover for PDF
      if (extension == 'pdf') {
        try {
          final appDocsDir = await getApplicationDocumentsDirectory();
          final librosDir = Directory(p.join(appDocsDir.path, 'libro_books'));
          if (!await librosDir.exists()) {
            await librosDir.create(recursive: true);
          }
          final document = await pdfx.PdfDocument.openFile(filePath);
          _totalPages = document.pagesCount;
          _pagesController.text = _totalPages.toString();
          final page = await document.getPage(1);
          final pageImage = await page.render(
            width: page.width,
            height: page.height,
            format: pdfx.PdfPageImageFormat.jpeg,
          );
          if (pageImage != null) {
            final tempId = DateTime.now().microsecondsSinceEpoch.toString();
            final coverFile = File(p.join(librosDir.path, '${tempId}_cover.jpg'));
            await coverFile.writeAsBytes(pageImage.bytes);
            _coverPath = coverFile.path;
          }
          await page.close();
          await document.close();
        } catch (e) {
          debugPrint('[Libro] Failed to generate cover: $e');
        }
      }

      setState(() {
        _currentStep = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _importBook() async {
    if (_pickedFilePath == null) return;
    setState(() => _isLoading = true);
    try {
      final originalFile = File(_pickedFilePath!);
      final appDocsDir = await getApplicationDocumentsDirectory();
      final librosDir = Directory(p.join(appDocsDir.path, 'libro_books'));
      if (!await librosDir.exists()) {
        await librosDir.create(recursive: true);
      }

      final newId = DateTime.now().microsecondsSinceEpoch.toString();
      final newPath = p.join(librosDir.path, '$newId.$_fileExtension');
      await originalFile.copy(newPath);

      final newBook = Book(
        id: newId,
        title: _titleController.text.isEmpty ? 'Untitled' : _titleController.text,
        author: _authorController.text.isEmpty ? 'Unknown Author' : _authorController.text,
        filePath: newPath,
        coverPath: _coverPath,
        fileType: _fileExtension,
        fileSize: _fileSize,
        dateAdded: DateTime.now(),
        totalPages: int.tryParse(_pagesController.text) ?? _totalPages,
        genre: _selectedGenre,
      );

      await ref.read(databaseServiceProvider).saveBook(newBook);
      await ref.read(bookListProvider.notifier).refresh();

      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing: $e')),
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
                    child: Text('Import Book', textAlign: TextAlign.center, style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
                    )),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Step Indicator ───
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepCircle(step: 1, isActive: _currentStep >= 0, isCompleted: _currentStep > 0),
                Container(
                  width: 64,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _currentStep > 0 ? AppTheme.accent : AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _StepCircle(step: 2, isActive: _currentStep >= 1, isCompleted: false),
              ],
            ),

            const SizedBox(height: 32),

            // ─── Content ───
            Expanded(
              child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.orangeGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.ctaShadow,
              ),
              child: const Icon(Icons.upload, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 32),
            const Text('Import Your Book', style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w500, color: AppTheme.textPrimary,
            )),
            const SizedBox(height: 12),
            const Text(
              'Drag and drop your PDF or EPUB file here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            // Choose File Button
            SizedBox(
              width: 160,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _pickFile,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Choose File'),
              ),
            ),
            const SizedBox(height: 32),
            // Supported Formats
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(children: [
                  Icon(Icons.description_outlined, size: 20, color: AppTheme.deleteRed),
                  const SizedBox(width: 8),
                  const Text('PDF', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                ]),
                const SizedBox(width: 32),
                Row(children: [
                  Icon(Icons.auto_stories_outlined, size: 20, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  const Text('EPUB', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
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
                    onPressed: _isLoading ? null : _importBook,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Import Book'),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.step, required this.isActive, required this.isCompleted});
  final int step;
  final bool isActive;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted ? AppTheme.accent : (isActive ? AppTheme.textPrimary : AppTheme.surfaceGray),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 18, color: Colors.white)
            : Text('$step', style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AppTheme.textMuted,
              )),
      ),
    );
  }
}
