import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/web_download.dart';

class CompanyPdfsScreen extends StatefulWidget {
  final String company;
  final String userId;

  const CompanyPdfsScreen({
    super.key,
    required this.company,
    required this.userId,
  });

  @override
  State<CompanyPdfsScreen> createState() => _CompanyPdfsScreenState();
}

class _CompanyPdfsScreenState extends State<CompanyPdfsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<String> _pdfFiles = [];
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadingFileName;

  // Dark theme colors
  static const Color _background = Color(0xFF1E232A);
  static const Color _elevatedSurface = Color(0xFF242A33);
  static const Color _cardSurface = Color(0xFF2A313B);
  static const Color _primaryText = Color(0xFFEDF9FF);
  static const Color _mutedText = Color(0xFF7F8A96);
  static const Color _primaryAccent = Color(0xFF6C5BFF);
  static const Color _accessoryAccent = Color(0xFFFE637E);
  static const Color _yellowAccent = Color(0xFFF8B800);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    _loadPdfFiles();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPdfFiles() async {
    setState(() {
      _isLoading = true;
      _pdfFiles = [];
    });

    try {
      final storage = FirebaseStorage.instance;
      final folderRef =
          storage.ref('procedures/${widget.userId}/${widget.company}');
      final result = await folderRef.listAll();

      // Filter out placeholder files
      final filtered = result.items
          .where((item) => !item.name.startsWith('.'))
          .map((item) => item.name)
          .toList();

      filtered.sort();

      setState(() {
        _pdfFiles = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnack('Error loading PDFs. Please try again.');
      }
    }
  }

  Future<String> _getPdfUrl(String filename) async {
    final ref = FirebaseStorage.instance
        .ref('procedures/${widget.userId}/${widget.company}/$filename');
    return await ref.getDownloadURL();
  }

  void _openPdfViewer(String filename) async {
    try {
      final url = await _getPdfUrl(filename);
      if (!mounted) return;

      if (kIsWeb) {
        openUrl(url);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _PdfViewerScreen(
              filename: filename,
              url: url,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) _showErrorSnack('Error opening PDF. Please try again.');
    }
  }

  Future<void> _uploadPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: kIsWeb,
        withReadStream: !kIsWeb,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final filename = file.name;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadingFileName = filename;
      });

      // Build the storage reference
      final ref = FirebaseStorage.instance
          .ref('procedures/${widget.userId}/${widget.company}/$filename');

      UploadTask uploadTask;

      if (kIsWeb) {
        if (file.bytes == null) {
          throw Exception('No file bytes available');
        }
        uploadTask = ref.putData(
          file.bytes!,
          SettableMetadata(contentType: 'application/pdf'),
        );
      } else {
        if (file.path == null) {
          throw Exception('No file path available');
        }
        uploadTask = ref.putFile(
          File(file.path!),
          SettableMetadata(contentType: 'application/pdf'),
        );
      }

      // Listen to progress
      uploadTask.snapshotEvents.listen((snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress =
                snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      await uploadTask;

      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadingFileName = null;
          _uploadProgress = 0.0;
        });
        _showSuccessSnack('"$filename" uploaded successfully!');
        _loadPdfFiles();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadingFileName = null;
          _uploadProgress = 0.0;
        });
        _showErrorSnack('Upload failed. Please try again.');
      }
    }
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFE637E)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(message,
                    style: const TextStyle(color: _primaryText))),
          ],
        ),
        backgroundColor: _elevatedSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00E5A8)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(message,
                    style: const TextStyle(color: _primaryText))),
          ],
        ),
        backgroundColor: _elevatedSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatCompanyName(String raw) {
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _formatCompanyName(widget.company);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _elevatedSurface,
        foregroundColor: _primaryText,
        elevation: 0,
        title: Text(
          '$displayName Procedures',
          style: const TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadPdfFiles,
            icon: Icon(Icons.refresh, color: _mutedText),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: _isUploading
          ? null
          : FloatingActionButton.extended(
              onPressed: _uploadPdf,
              backgroundColor: _primaryAccent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text(
                'Upload PDF',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload progress banner
              if (_isUploading)
                _buildUploadProgressBanner(),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: _cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _yellowAccent.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.folder_open_rounded,
                                size: 28,
                                color: _yellowAccent,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Tap a PDF to open it, or upload a new one',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // List content
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: _primaryAccent,
                                ),
                              )
                            : _pdfFiles.isEmpty
                                ? _buildEmptyState()
                                : _buildPdfList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadProgressBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _elevatedSurface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _primaryAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Uploading "${_uploadingFileName ?? 'file'}"...',
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: _primaryAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _uploadProgress,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(_primaryAccent),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _cardSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.upload_file_rounded,
              size: 48,
              color: _mutedText.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No procedures yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Upload PDF" below to add\nyour first procedure document.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: _mutedText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _uploadPdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryAccent,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text(
              'Upload PDF',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfList() {
    return ListView.builder(
      itemCount: _pdfFiles.length,
      itemBuilder: (context, index) {
        final filename = _pdfFiles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPdfCard(filename),
        );
      },
    );
  }

  Widget _buildPdfCard(String filename) {
    // Strip .pdf extension for display
    final displayName = filename.toLowerCase().endsWith('.pdf')
        ? filename.substring(0, filename.length - 4)
        : filename;

    return Container(
      decoration: BoxDecoration(
        color: _cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPdfViewer(filename),
          borderRadius: BorderRadius.circular(14),
          hoverColor: Colors.white.withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // PDF icon badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _accessoryAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: _accessoryAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tap to open',
                        style: TextStyle(
                          fontSize: 12,
                          color: _mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: _primaryAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen PDF viewer for mobile
class _PdfViewerScreen extends StatelessWidget {
  final String filename;
  final String url;

  const _PdfViewerScreen({
    required this.filename,
    required this.url,
  });

  static const Color _background = Color(0xFF1E232A);
  static const Color _elevatedSurface = Color(0xFF242A33);
  static const Color _primaryText = Color(0xFFEDF9FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _elevatedSurface,
        foregroundColor: _primaryText,
        elevation: 0,
        title: Text(
          filename,
          style: const TextStyle(color: _primaryText, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SfPdfViewer.network(
        url,
        onDocumentLoadFailed: (details) async {
          // Fallback: download locally and use flutter_pdfview
          try {
            final tempDir = await getTemporaryDirectory();
            final filePath = '${tempDir.path}/$filename';
            final response = await http.get(Uri.parse(url));
            final file = File(filePath);
            await file.writeAsBytes(response.bodyBytes);

            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    backgroundColor: _background,
                    appBar: AppBar(
                      backgroundColor: _elevatedSurface,
                      foregroundColor: _primaryText,
                      elevation: 0,
                      title: Text(
                        filename,
                        style: const TextStyle(
                            color: _primaryText, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    body: PDFView(filePath: filePath),
                  ),
                ),
              );
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to load PDF.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
