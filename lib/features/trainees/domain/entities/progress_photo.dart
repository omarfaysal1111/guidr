import 'package:equatable/equatable.dart';

/// Single progress photo on a trainee profile (`progressPhotos` from API).
class ProgressPhoto extends Equatable {
  final String id;
  final String fileUrl;
  final DateTime? uploadedAt;
  final String? fileName;
  final String? caption;

  const ProgressPhoto({
    required this.id,
    required this.fileUrl,
    this.uploadedAt,
    this.fileName,
    this.caption,
  });

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    String pickUrl() {
      for (final k in ['file_url', 'fileUrl', 'url', 'imageUrl', 'storageUrl', 'path']) {
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

    return ProgressPhoto(
      id: json['id']?.toString() ?? '',
      fileUrl: pickUrl(),
      uploadedAt: at,
      fileName: _pickStr(json, ['file_name', 'fileName', 'originalName', 'name']),
      caption: _pickStr(json, ['caption', 'note', 'description']),
    );
  }

  static String? _pickStr(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  @override
  List<Object?> get props => [id, fileUrl, uploadedAt, fileName, caption];
}

List<ProgressPhoto> parseProgressPhotosList(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map<String, dynamic>>()
      .map(ProgressPhoto.fromJson)
      .where((e) => e.fileUrl.isNotEmpty)
      .toList();
}
