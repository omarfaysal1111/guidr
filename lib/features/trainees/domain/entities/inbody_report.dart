import 'package:equatable/equatable.dart';

/// Single InBody (or similar) composition report attached to a trainee profile.
///
/// API may expose `inbodyReports` / `inbody_reports` with `file_url` (or camelCase).
class InBodyReport extends Equatable {
  final String id;
  final String fileUrl;
  final DateTime? uploadedAt;
  final String? fileName;
  final String? mimeType;

  const InBodyReport({
    required this.id,
    required this.fileUrl,
    this.uploadedAt,
    this.fileName,
    this.mimeType,
  });

  factory InBodyReport.fromJson(Map<String, dynamic> json) {
    String pickUrl() {
      for (final k in ['file_url', 'fileUrl', 'url', 'storageUrl', 'path']) {
        final v = json[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
      return '';
    }

    DateTime? at;
    final rawDate = json['uploadedAt'] ?? json['createdAt'] ?? json['recordedAt'];
    if (rawDate is String && rawDate.isNotEmpty) {
      at = DateTime.tryParse(rawDate);
    }

    return InBodyReport(
      id: json['id']?.toString() ?? '',
      fileUrl: pickUrl(),
      uploadedAt: at,
      fileName: _pickStr(json, ['file_name', 'fileName', 'originalName', 'name']),
      mimeType: _pickStr(json, ['mime_type', 'mimeType', 'contentType', 'content_type']),
    );
  }

  static String? _pickStr(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  bool get isPdf {
    final m = mimeType?.toLowerCase();
    if (m != null && m.contains('pdf')) return true;
    return fileUrl.toLowerCase().split('?').first.endsWith('.pdf');
  }

  bool get isImage {
    final m = mimeType?.toLowerCase();
    if (m != null && m.startsWith('image/')) return true;
    final u = fileUrl.toLowerCase().split('?').first;
    return u.endsWith('.png') ||
        u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.gif') ||
        u.endsWith('.webp') ||
        u.endsWith('.heic');
  }

  @override
  List<Object?> get props => [id, fileUrl, uploadedAt, fileName, mimeType];
}

List<InBodyReport> parseInBodyReportsList(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(InBodyReport.fromJson)
      .where((e) => e.fileUrl.isNotEmpty)
      .toList();
}
