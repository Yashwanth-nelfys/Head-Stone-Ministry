import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    this.title = 'Message Notes',
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? _localPath;

  bool _isLoading = true;

  String? _errorMessage;

  int _currentPage = 0;

  int _totalPages = 0;

  PDFViewController? _pdfController;

  @override
  void initState() {
    super.initState();

    _downloadPdf();
  }

  // ==========================================================
  // DOWNLOAD PDF FROM URL
  // ==========================================================

  Future<void> _downloadPdf() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      debugPrint('Downloading PDF:');

      debugPrint(widget.pdfUrl);

      final uri = Uri.parse(widget.pdfUrl);

      final response = await http.get(
        uri,
        headers: const {'Accept': 'application/pdf'},
      );

      debugPrint('PDF HTTP Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception(
          'Unable to download PDF. '
          'HTTP status: ${response.statusCode}',
        );
      }

      if (response.bodyBytes.isEmpty) {
        throw Exception('The downloaded PDF is empty.');
      }

      // ======================================================
      // GET TEMP DIRECTORY
      // ======================================================

      final directory = await getTemporaryDirectory();

      final fileName =
          'message_notes_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);

      // ======================================================
      // SAVE PDF
      // ======================================================

      await file.writeAsBytes(response.bodyBytes, flush: true);

      debugPrint('PDF saved at:');

      debugPrint(filePath);

      // ======================================================
      // VERIFY FILE
      // ======================================================

      final exists = await file.exists();

      final fileSize = await file.length();

      debugPrint('PDF exists: $exists');

      debugPrint('PDF size: $fileSize bytes');

      if (!exists || fileSize == 0) {
        throw Exception('PDF file could not be created.');
      }

      if (!mounted) return;

      setState(() {
        _localPath = filePath;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('PDF ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;

        _errorMessage = e.toString();
      });
    }
  }

  // ==========================================================
  // RETRY
  // ==========================================================

  Future<void> _retry() async {
    setState(() {
      _localPath = null;

      _isLoading = true;

      _errorMessage = null;

      _currentPage = 0;

      _totalPages = 0;
    });

    await _downloadPdf();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _pdfController = null;

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDEFF3),

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        backgroundColor: Colors.white,

        surfaceTintColor: Colors.white,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F7),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Color(0xFF222222),
            ),
          ),
        ),

        title: Text(
          widget.title,

          maxLines: 1,

          overflow: TextOverflow.ellipsis,

          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Color(0xFF171717),
          ),
        ),

        actions: [
          if (_totalPages > 0)
            Container(
              margin: const EdgeInsets.only(right: 14),

              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),

              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F8),

                borderRadius: BorderRadius.circular(10),
              ),

              child: Text(
                '${_currentPage + 1} / $_totalPages',

                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF555555),
                ),
              ),
            ),
        ],
      ),

      body: _buildBody(),
    );
  }

  // ==========================================================
  // BODY
  // ==========================================================

  Widget _buildBody() {
    // ========================================================
    // LOADING
    // ========================================================

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            SizedBox(
              width: 38,
              height: 38,

              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xFF3157D5),
              ),
            ),

            SizedBox(height: 18),

            Text(
              'Loading message notes...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF555555),
              ),
            ),

            SizedBox(height: 6),

            Text(
              'Preparing PDF for viewing',
              style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }

    // ========================================================
    // ERROR
    // ========================================================

    if (_errorMessage != null || _localPath == null) {
      return _buildErrorView();
    }

    // ========================================================
    // PDF VIEW
    // ========================================================

    return Stack(
      children: [
        PDFView(
          filePath: _localPath!,

          // Enable vertical swipe
          enableSwipe: true,

          swipeHorizontal: false,

          // Smooth page snapping
          pageFling: true,

          pageSnap: true,

          autoSpacing: true,

          // Start from first page
          defaultPage: 0,

          // Fit PDF width to screen
          fitPolicy: FitPolicy.WIDTH,

          // Allow links inside PDF
          preventLinkNavigation: false,

          // ==================================================
          // PDF RENDERED
          // ==================================================
          onRender: (pages) {
            debugPrint('PDF rendered successfully');

            debugPrint('Pages: $pages');

            if (!mounted) return;

            setState(() {
              _totalPages = pages ?? 0;
            });
          },

          // ==================================================
          // CONTROLLER
          // ==================================================
          onViewCreated: (PDFViewController controller) {
            _pdfController = controller;
          },

          // ==================================================
          // PAGE CHANGED
          // ==================================================
          onPageChanged: (page, total) {
            if (!mounted) return;

            setState(() {
              _currentPage = page ?? 0;

              _totalPages = total ?? 0;
            });
          },

          // ==================================================
          // PDF ERROR
          // ==================================================
          onError: (error) {
            debugPrint('PDF Viewer Error: $error');

            if (!mounted) return;

            setState(() {
              _errorMessage = error.toString();
            });
          },

          // ==================================================
          // PAGE ERROR
          // ==================================================
          onPageError: (page, error) {
            debugPrint('PDF Page Error');

            debugPrint('Page: $page');

            debugPrint('Error: $error');
          },
        ),

        // ====================================================
        // PAGE INDICATOR
        // ====================================================
        if (_totalPages > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,

            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),

                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.78),

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),

                      blurRadius: 12,

                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.description_outlined,

                      color: Colors.white,

                      size: 16,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',

                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 12,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================
  // ERROR VIEW
  // ==========================================================

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // ==================================================
            // ICON
            // ==================================================
            Container(
              width: 78,
              height: 78,

              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEA),

                borderRadius: BorderRadius.circular(23),
              ),

              child: const Icon(
                Icons.picture_as_pdf_rounded,

                color: Color(0xFFE53935),

                size: 40,
              ),
            ),

            const SizedBox(height: 22),

            // ==================================================
            // TITLE
            // ==================================================
            const Text(
              'Unable to open PDF',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 20,

                fontWeight: FontWeight.w800,

                color: Color(0xFF171717),
              ),
            ),

            const SizedBox(height: 10),

            // ==================================================
            // DESCRIPTION
            // ==================================================
            const Text(
              'The message notes could not be loaded. '
              'Please check your internet connection '
              'and try again.',

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 13,

                height: 1.5,

                color: Color(0xFF777777),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ERROR DETAILS
            // ==================================================
            if (_errorMessage != null)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),

                child: Text(
                  _errorMessage!,

                  maxLines: 4,

                  overflow: TextOverflow.ellipsis,

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 10,

                    color: Color(0xFF999999),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ==================================================
            // RETRY BUTTON
            // ==================================================
            SizedBox(
              height: 48,

              child: ElevatedButton.icon(
                onPressed: _retry,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3157D5),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  padding: const EdgeInsets.symmetric(horizontal: 24),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                icon: const Icon(Icons.refresh_rounded, size: 19),

                label: const Text(
                  'Try Again',

                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
