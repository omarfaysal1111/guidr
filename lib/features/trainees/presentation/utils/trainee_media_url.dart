import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Same host rules as [ApiClient] in `core/network/api_client.dart` (without `/api` prefix).
String _traineeMediaHost() {
  if (kIsWeb) return 'http://localhost:8080';
  if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:8080';
  return 'http://localhost:8080';
}

/// Builds a full [Uri] for trainee media when the API returns a relative path.
Uri resolveTraineeMediaUrl(String fileUrl) {
  final t = fileUrl.trim();
  if (t.isEmpty) return Uri();
  if (t.startsWith('http://') || t.startsWith('https://')) return Uri.parse(t);
  final host = _traineeMediaHost();
  if (t.startsWith('/')) return Uri.parse('$host$t');
  return Uri.parse('$host/$t');
}
