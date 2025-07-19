import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/question_model.dart';
import '../theme/app_theme.dart';

class QuestionCard extends StatefulWidget {
  final Question question;

  const QuestionCard({required this.question, Key? key}) : super(key: key);

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  // Controller for zoom level
  late PhotoViewController _controller;
  // Track current zoom scale
  double _currentScale = 1.0;
  // PDF related variables
  String? _localPdfPath;
  bool _isLoadingPdf = false;
  int _currentPdfPage = 0;
  int _totalPdfPages = 0;
  late PDFViewController _pdfController;

  @override
  void initState() {
    super.initState();
    _controller = PhotoViewController(initialScale: 1.0);
    // Listen to scale changes from the controller
    _controller.outputStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _currentScale = state.scale ?? 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Handler to zoom in with specific increments (30%, 40%, 50%, etc.)
  void _zoomIn() {
    // Round current percentage to nearest 10
    int currentPercent = (_currentScale * 100).round();
    // Find next zoom level (next 10% increment)
    int nextPercent = ((currentPercent / 10).ceil() * 10) + 10;
    // Ensure we don't exceed maximum zoom (200%)
    nextPercent = nextPercent.clamp(30, 200);
    // Convert percentage back to scale factor
    _controller.scale = nextPercent / 100;
  }

  // Handler to zoom out with specific increments
  void _zoomOut() {
    // Round current percentage to nearest 10
    int currentPercent = (_currentScale * 100).round();
    // Find previous zoom level (previous 10% increment)
    int prevPercent = ((currentPercent / 10).floor() * 10) - 10;
    // Ensure we don't go below minimum zoom (30%)
    prevPercent = prevPercent.clamp(30, 200);
    // Convert percentage back to scale factor
    _controller.scale = prevPercent / 100;
  }

  // Reset zoom to 100% (contained view)
  void _resetZoom() {
    _controller.scale = 1.0;
  }

  // Helper method to check if URL is a PDF
  bool _isPdfUrl(String url) {
    return url.toLowerCase().endsWith('.pdf') ||
        url.toLowerCase().contains('.pdf?') ||
        url.toLowerCase().contains('pdf');
  }

  // Helper method to download PDF file
  Future<void> _downloadPdf(String url) async {
    if (_isLoadingPdf) return;

    setState(() {
      _isLoadingPdf = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file =
            File('${dir.path}/question_${widget.question.title.hashCode}.pdf');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _localPdfPath = file.path;
          _isLoadingPdf = false;
        });
      } else {
        setState(() {
          _isLoadingPdf = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingPdf = false;
      });
    }
  }

  // PDF page navigation methods
  void _goToPreviousPage() {
    if (_currentPdfPage > 0) {
      _pdfController.setPage(_currentPdfPage - 1);
    }
  }

  void _goToNextPage() {
    if (_currentPdfPage < _totalPdfPages - 1) {
      _pdfController.setPage(_currentPdfPage + 1);
    }
  }

  // Helper method to build PDF viewer
  Widget _buildPdfViewer() {
    if (_isLoadingPdf) {
      return Container(
        height: 650,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                "Loading PDF...",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_localPdfPath == null) {
      return Container(
        height: 650,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.picture_as_pdf,
                color: Colors.grey,
                size: 40,
              ),
              SizedBox(height: 8),
              Text(
                "Failed to load PDF",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 650,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // PDF Viewer
            PDFView(
              filePath: _localPdfPath!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: false,
              pageFling: false,
              onRender: (pages) {
                setState(() {
                  _totalPdfPages = pages!;
                });
              },
              onViewCreated: (PDFViewController pdfViewController) {
                _pdfController = pdfViewController;
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPdfPage = page!;
                });
              },
              onError: (error) {
                print('PDF Error: $error');
              },
            ),

            // PDF Navigation Controls
            Positioned(
              bottom: 20,
              right: 20,
              child: Column(
                children: [
                  // Previous page button
                  _buildPdfButton(
                    icon: Icons.keyboard_arrow_up,
                    onPressed: _currentPdfPage > 0 ? _goToPreviousPage : null,
                    tooltip: 'Previous page',
                  ),
                  SizedBox(height: 8),
                  // Next page button
                  _buildPdfButton(
                    icon: Icons.keyboard_arrow_down,
                    onPressed: _currentPdfPage < _totalPdfPages - 1
                        ? _goToNextPage
                        : null,
                    tooltip: 'Next page',
                  ),
                ],
              ),
            ),

            // PDF Page indicator
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "${_currentPdfPage + 1} / $_totalPdfPages",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If question has an image or PDF, display the appropriate viewer
    if (widget.question.image.isNotEmpty) {
      // Check if it's a PDF
      if (_isPdfUrl(widget.question.image)) {
        // Initialize PDF download if not already done
        if (_localPdfPath == null && !_isLoadingPdf) {
          _downloadPdf(widget.question.image);
        }
        return _buildPdfViewer();
      }

      // Otherwise, display image with zoom capabilities
      return Container(
        height: 650,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Zoom and pan enabled PhotoView
              PhotoView(
                imageProvider:
                    CachedNetworkImageProvider(widget.question.image),
                backgroundDecoration: BoxDecoration(
                  color: Colors.grey.shade50,
                ),
                minScale:
                    PhotoViewComputedScale.contained * 0.3, // 30% minimum zoom
                maxScale:
                    PhotoViewComputedScale.contained * 2.0, // 200% maximum zoom
                initialScale: PhotoViewComputedScale.contained,
                controller: _controller,
                enableRotation: false,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 40,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Image not found",
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? 0
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                  ),
                ),
              ),

              // Zoom controls
              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  children: [
                    // Zoom in button
                    _buildZoomButton(
                      icon: Icons.add,
                      onPressed: _zoomIn,
                      tooltip: 'Zoom in',
                    ),
                    SizedBox(height: 8),
                    // Zoom out button
                    _buildZoomButton(
                      icon: Icons.remove,
                      onPressed: _zoomOut,
                      tooltip: 'Zoom out',
                    ),
                    SizedBox(height: 8),
                    // Reset zoom button
                    _buildZoomButton(
                      icon: Icons.restart_alt,
                      onPressed: _resetZoom,
                      tooltip: 'Reset zoom',
                    ),
                  ],
                ),
              ),

              // Zoom level indicator
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "${(_currentScale * 100).toInt()}%",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If no image, display the current layout with title and description HTML
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 600,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Title
              Container(
                padding: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.question_mark_rounded,
                        color: AppTheme.primaryColor,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.question.title,
                        style: TextStyle(
                          color: AppTheme.textPrimaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Question Description with HTML content
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Html(
                  data: widget.question.description,
                  style: {
                    "p": Style(
                      fontSize: FontSize(18),
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      lineHeight: LineHeight(1.5),
                      color: AppTheme.textPrimaryColor,
                    ),
                    "ul": Style(
                      margin: Margins.only(left: 20),
                      fontSize: FontSize(18),
                    ),
                    "li": Style(
                      fontSize: FontSize(18),
                      margin: Margins.only(bottom: 8),
                      color: AppTheme.textPrimaryColor,
                    ),
                    "strong": Style(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                    "em": Style(
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecondaryColor,
                    ),
                    "img": Style(
                      width: Width(100, Unit.percent),
                      alignment: Alignment.center,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build zoom control buttons
  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: AppTheme.primaryColor,
        tooltip: tooltip,
        iconSize: 20,
      ),
    );
  }

  // Helper method to build PDF navigation buttons
  Widget _buildPdfButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: onPressed != null ? AppTheme.primaryColor : Colors.grey,
        tooltip: tooltip,
        iconSize: 20,
      ),
    );
  }
}
