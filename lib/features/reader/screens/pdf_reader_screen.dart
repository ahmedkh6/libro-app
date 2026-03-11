import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../data/models/book.dart';
import '../../../data/models/reading_progress.dart';
import '../../../data/models/bookmark.dart';
import '../../library/providers/book_provider.dart';
import '../../../core/widgets/fade_up_animation.dart';

class PdfReaderScreen extends ConsumerStatefulWidget {
  final Book book;

  const PdfReaderScreen({super.key, required this.book});

  @override
  ConsumerState<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends ConsumerState<PdfReaderScreen>
    with SingleTickerProviderStateMixin {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  
  // Localized state to prevent full screen rebuilds
  late final ValueNotifier<bool> _showUINotifier;
  late final ValueNotifier<int> _currentPageNotifier;
  late final ValueNotifier<int> _totalPagesNotifier;
  late final ValueNotifier<double> _brightnessNotifier;
  late final ValueNotifier<PdfPageLayoutMode> _layoutModeNotifier;
  late final ValueNotifier<bool> _isBookmarkedNotifier;
  late final ValueNotifier<String?> _selectedTextNotifier;

  late AnimationController _uiAnimController;
  late Animation<double> _uiAnimation;

  bool _isDocumentLoaded = false;
  Offset? _pointerDownPosition;

  // Auto-hide & debounced save timers
  Timer? _autoHideTimer;
  Timer? _saveProgressTimer;
  static const _autoHideDuration = Duration(seconds: 4);

  // We maintain the latest state independently to save robustly
  late Book _currentBookState;

  @override
  void initState() {
    super.initState();
    _currentBookState = widget.book;
    
    _showUINotifier = ValueNotifier(true);
    _currentPageNotifier = ValueNotifier(widget.book.readingProgress?.currentPage ?? 1);
    _totalPagesNotifier = ValueNotifier(widget.book.totalPages ?? 1);
    _brightnessNotifier = ValueNotifier(1.0);
    _layoutModeNotifier = ValueNotifier(PdfPageLayoutMode.continuous);
    _isBookmarkedNotifier = ValueNotifier(false);
    _selectedTextNotifier = ValueNotifier(null);

    _uiAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _uiAnimation = CurvedAnimation(parent: _uiAnimController, curve: Curves.easeInOut);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startAutoHideTimer();
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _saveProgressTimer?.cancel();
    _uiAnimController.dispose();
    
    _showUINotifier.dispose();
    _currentPageNotifier.dispose();
    _totalPagesNotifier.dispose();
    _brightnessNotifier.dispose();
    _layoutModeNotifier.dispose();
    _isBookmarkedNotifier.dispose();
    _selectedTextNotifier.dispose();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    // Aggressively save progress right as we close
    _forceSaveProgress();
    
    super.dispose();
  }

  void _debouncedSaveProgress() {
    _saveProgressTimer?.cancel();
    // Run saving in a background microtask essentially after 1.5s to not block active scrolling
    _saveProgressTimer = Timer(const Duration(milliseconds: 1500), _forceSaveProgress);
  }

  void _forceSaveProgress() {
    if (!_isDocumentLoaded) return;
    
    final current = _currentPageNotifier.value;
    final total = _totalPagesNotifier.value;

    final progress = ReadingProgress(
      currentPage: current,
      progressPercent: total > 0 ? current / total : 0.0,
      lastReadAt: DateTime.now(),
    );
    final updatedBook = _currentBookState.copyWith(
      readingProgress: progress,
      totalPages: total,
      status: current >= total ? BookStatus.finished : BookStatus.reading,
    );
    _currentBookState = updatedBook;
    
    // Ensure the riverpod update is unawaited to keep UI thread clean
    Future.microtask(() {
      if (mounted) {
        ref.read(bookListProvider.notifier).updateBook(updatedBook);
      }
    });
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(_autoHideDuration, () {
      if (_showUINotifier.value && mounted) {
        _hideUI();
      }
    });
  }

  void _showUIBars() {
    if (!_showUINotifier.value) {
      _showUINotifier.value = true;
      _uiAnimController.forward();
    }
    _startAutoHideTimer();
  }

  void _hideUI() {
    _autoHideTimer?.cancel();
    _showUINotifier.value = false;
    _uiAnimController.reverse();
  }

  void _toggleUI() {
    if (_showUINotifier.value) {
      _hideUI();
    } else {
      _showUIBars();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // We keep the build method extremely light.
    // The SfPdfViewer is only rebuilt when _layoutModeNotifier changes.
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // PDF Content
          // Optimization: Extracted Opacity widget which forced heavily expensive layer compositing
          ValueListenableBuilder<PdfPageLayoutMode>(
            valueListenable: _layoutModeNotifier,
            builder: (context, layoutMode, _) {
              return Listener(
                onPointerDown: (event) => _pointerDownPosition = event.position,
                onPointerUp: (event) {
                  if (_pointerDownPosition != null) {
                    final distance = (event.position - _pointerDownPosition!).distance;
                    if (distance < 10) {
                      if (_selectedTextNotifier.value != null) {
                        _pdfViewerController.clearSelection();
                        _selectedTextNotifier.value = null;
                      } else {
                        _toggleUI();
                      }
                    }
                  }
                },
                child: SfPdfViewer.file(
                  File(widget.book.filePath),
                  controller: _pdfViewerController,
                  canShowScrollHead: false, // Disabling unnecessary visual overlays from PDF viewer
                  canShowScrollStatus: false,
                  canShowPaginationDialog: false,
                  pageSpacing: 2,
                  pageLayoutMode: layoutMode,
                  scrollDirection: layoutMode == PdfPageLayoutMode.single
                      ? PdfScrollDirection.horizontal
                      : PdfScrollDirection.vertical,
                  onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                    _totalPagesNotifier.value = details.document.pages.count;
                    _isDocumentLoaded = true;
                    if (_currentBookState.readingProgress?.currentPage != null) {
                      _pdfViewerController.jumpToPage(_currentBookState.readingProgress!.currentPage!);
                    }
                    _forceSaveProgress();
                  },
                  onPageChanged: (PdfPageChangedDetails details) {
                    _currentPageNotifier.value = details.newPageNumber;
                    
                    // Optimization: Debounce progress updates to keep scrolling smooth
                    _debouncedSaveProgress();
                    
                    if (_showUINotifier.value) _startAutoHideTimer();
                  },
                  onTextSelectionChanged: (PdfTextSelectionChangedDetails details) {
                    if (details.selectedText != null && details.selectedText!.isNotEmpty) {
                      Future.microtask(() {
                        if (mounted) {
                          _selectedTextNotifier.value = details.selectedText;
                          _showUINotifier.value = false;
                        }
                      });
                    } else {
                      Future.microtask(() {
                        if (mounted) {
                          _selectedTextNotifier.value = null;
                        }
                      });
                    }
                  },
                ),
              );
            },
          ),

          // Brightness Overlay (replaces Opacity on the PDF viewer for massive perf gain)
          ValueListenableBuilder<double>(
            valueListenable: _brightnessNotifier,
            builder: (context, brightness, child) {
              if (brightness >= 1.0) return const SizedBox.shrink();
              return IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(1.0 - brightness),
                ),
              );
            },
          ),

          // Header
          Positioned(
            top: 0, left: 0, right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _showUINotifier,
              builder: (context, showUI, child) {
                return IgnorePointer(
                  ignoring: !showUI,
                  child: FadeTransition(
                    opacity: _uiAnimation,
                    child: _buildHeader(theme),
                  ),
                );
              },
            ),
          ),

          // Text Selection Bookmark Popup
          ValueListenableBuilder<String?>(
            valueListenable: _selectedTextNotifier,
            builder: (context, selectedText, child) {
              if (selectedText == null) return const SizedBox.shrink();
              return Positioned(
                bottom: 40,
                left: 24,
                right: 24,
                child: FadeUpAnimation(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '"$selectedText"',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                _pdfViewerController.clearSelection();
                                _selectedTextNotifier.value = null;
                              },
                              child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                final page = _currentPageNotifier.value;
                                final bookmark = Bookmark(text: selectedText, page: page, createdAt: DateTime.now());
                                final updatedBookmarks = List<Bookmark>.from(_currentBookState.bookmarks ?? [])..add(bookmark);
                                final updatedBook = _currentBookState.copyWith(bookmarks: updatedBookmarks);
                                _currentBookState = updatedBook;
                                ref.read(bookListProvider.notifier).updateBook(updatedBook);
                                
                                _pdfViewerController.clearSelection();
                                _selectedTextNotifier.value = null;
                                
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmark saved!')));
                              },
                              icon: const Icon(Icons.bookmark_add, size: 18),
                              label: const Text('Save Bookmark'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Footer
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _showUINotifier,
              builder: (context, showUI, child) {
                return IgnorePointer(
                  ignoring: !showUI,
                  child: FadeTransition(
                    opacity: _uiAnimation,
                    child: _buildFooter(theme),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05))),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _forceSaveProgress();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _currentBookState.title,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentBookState.author.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _autoHideTimer?.cancel();
                      _showReaderSettings(context, theme);
                    },
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: ValueListenableBuilder<int>(
            valueListenable: _currentPageNotifier,
            builder: (context, currentPage, _) {
              return ValueListenableBuilder<int>(
                valueListenable: _totalPagesNotifier,
                builder: (context, totalPages, _) {
                  final remainingPages = totalPages > 0 ? totalPages - currentPage : 0;
                  final estimatedMinutes = (remainingPages * 1.5).ceil().clamp(0, 9999);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PAGE $currentPage OF $totalPages',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            '$estimatedMinutes MIN REMAINING',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          activeTrackColor: theme.colorScheme.onSurface,
                          inactiveTrackColor: theme.colorScheme.onSurface.withOpacity(0.1),
                          thumbColor: theme.colorScheme.onSurface,
                          overlayColor: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                        child: Slider(
                          value: currentPage.toDouble().clamp(1.0, totalPages.toDouble().clamp(1.0, double.infinity)),
                          min: 1.0,
                          max: totalPages.toDouble().clamp(1.0, double.infinity),
                          onChanged: (value) {
                            _pdfViewerController.jumpToPage(value.toInt());
                            _startAutoHideTimer();
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showReaderSettings(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: theme.colorScheme.shadow.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, -10)),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeUpAnimation(
                    delayMs: 100,
                    child: Text(
                      'READING.',
                      style: theme.textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Brightness
                  FadeUpAnimation(
                    delayMs: 200,
                    child: Text('BRIGHTNESS', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2.0, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ),
                  const SizedBox(height: 16),
                  FadeUpAnimation(
                    delayMs: 250,
                    child: Row(
                      children: [
                        Icon(Icons.brightness_low, size: 24, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              activeTrackColor: theme.colorScheme.secondary,
                              inactiveTrackColor: theme.colorScheme.onSurface.withOpacity(0.1),
                              thumbColor: theme.colorScheme.secondary,
                            ),
                            child: ValueListenableBuilder<double>(
                              valueListenable: _brightnessNotifier,
                              builder: (context, brightness, _) {
                                return Slider(
                                  value: brightness,
                                  min: 0.3,
                                  max: 1.0,
                                  onChanged: (v) {
                                    _brightnessNotifier.value = v;
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        Icon(Icons.brightness_high, size: 24, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Layout Mode
                  FadeUpAnimation(
                    delayMs: 300,
                    child: Text('LAYOUT MODE', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2.0, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ),
                  const SizedBox(height: 16),
                  FadeUpAnimation(
                    delayMs: 350,
                    child: ValueListenableBuilder<PdfPageLayoutMode>(
                      valueListenable: _layoutModeNotifier,
                      builder: (context, layoutMode, _) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildLayoutOption(
                                theme,
                                'Single Page',
                                layoutMode == PdfPageLayoutMode.single,
                                () {
                                  _layoutModeNotifier.value = PdfPageLayoutMode.single;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildLayoutOption(
                                theme,
                                'Continuous Scroll',
                                layoutMode == PdfPageLayoutMode.continuous,
                                () {
                                  _layoutModeNotifier.value = PdfPageLayoutMode.continuous;
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _startAutoHideTimer();
    });
  }

  Widget _buildLayoutOption(ThemeData theme, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? theme.colorScheme.secondary : theme.colorScheme.onSurface.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: isActive ? theme.colorScheme.onSecondary : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}
