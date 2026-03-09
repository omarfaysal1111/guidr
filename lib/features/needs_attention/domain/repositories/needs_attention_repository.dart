import '../entities/attention_item.dart';

abstract class NeedsAttentionRepository {
  /// Fetches items that need coach attention.
  /// [limit] - max items to return (default 10)
  /// [offset] - pagination offset (default 0)
  /// [type] - optional filter by alert type: 'missed', 'nutrition', 'noLogin', 'plateau'
  Future<List<AttentionItem>> getNeedsAttention({
    int limit = 10,
    int offset = 0,
    String? type,
  });
}
