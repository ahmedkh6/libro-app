import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// A widget that renders the first page of a PDF as a book cover thumbnail.
/// Falls back to a styled icon card if rendering fails.
class PdfCoverThumbnail extends StatelessWidget {
  final String filePath;
  final double width;
  final double height;
  final Color accentColor;

  const PdfCoverThumbnail({
    super.key,
    required this.filePath,
    this.width = double.infinity,
    this.height = double.infinity,
    this.accentColor = const Color(0xFF3211D4),
  });

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: width,
        height: height,
        child: IgnorePointer(
          child: SfPdfViewer.file(
            file,
            canShowScrollHead: false,
            canShowScrollStatus: false,
            canShowPaginationDialog: false,
            pageLayoutMode: PdfPageLayoutMode.single,
            scrollDirection: PdfScrollDirection.horizontal,
            enableDoubleTapZooming: false,
            enableTextSelection: false,
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          Icons.picture_as_pdf,
          size: 48,
          color: accentColor.withOpacity(0.3),
        ),
      ),
    );
  }
}
