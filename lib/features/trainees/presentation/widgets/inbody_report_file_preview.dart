import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';

import '../../../../core/theme/app_colors.dart';

/// Renders an InBody report from a resolved URL: images via [Image.network], PDF via [pdfx].
class InBodyReportFilePreview extends StatefulWidget {
  final Uri uri;
  final bool isPdf;
  final bool isImage;

  const InBodyReportFilePreview({
    super.key,
    required this.uri,
    required this.isPdf,
    required this.isImage,
  });

  @override
  State<InBodyReportFilePreview> createState() => _InBodyReportFilePreviewState();
}

class _InBodyReportFilePreviewState extends State<InBodyReportFilePreview> {
  PdfControllerPinch? _pdfController;

  static bool get _isWindowsDesktop =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  @override
  void initState() {
    super.initState();
    if (widget.isPdf && !_isWindowsDesktop) {
      _pdfController = PdfControllerPinch(document: _loadPdf(widget.uri));
    }
  }

  Future<PdfDocument> _loadPdf(Uri uri) async {
    final res = await http.get(uri);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Download failed (${res.statusCode})');
    }
    return PdfDocument.openData(res.bodyBytes);
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.uri.toString();
    if (url.isEmpty) {
      return const _PreviewError(message: 'Missing file URL.');
    }

    if (widget.isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              );
            },
            errorBuilder: (_, __, ___) => _PreviewError(
              message: 'Could not load image.',
              url: url,
            ),
          ),
        ),
      );
    }

    if (widget.isPdf) {
      if (_isWindowsDesktop) {
        return _PreviewError(
          message: 'Inline PDF preview is not available on Windows. Use the URL below in a browser.',
          url: url,
        );
      }
      final c = _pdfController;
      if (c == null) {
        return const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 380,
          child: PdfViewPinch(
            controller: c,
            onDocumentError: (err) {
              debugPrint('PdfViewPinch error: $err');
            },
          ),
        ),
      );
    }

    return _PreviewError(
      message: 'Unsupported file type. Open the URL manually if needed.',
      url: url,
    );
  }
}

class _PreviewError extends StatelessWidget {
  final String message;
  final String? url;

  const _PreviewError({required this.message, this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined, color: AppColors.textMuted.withValues(alpha: 0.8)),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          if (url != null && url!.isNotEmpty) ...[
            const SizedBox(height: 8),
            SelectableText(
              url!,
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}
