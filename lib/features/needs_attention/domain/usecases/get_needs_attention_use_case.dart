import '../entities/attention_item.dart';
import '../repositories/needs_attention_repository.dart';

class GetNeedsAttentionUseCase {
  final NeedsAttentionRepository repository;

  GetNeedsAttentionUseCase(this.repository);

  Future<List<AttentionItem>> call({
    int limit = 10,
    int offset = 0,
    String? type,
  }) async {
    return repository.getNeedsAttention(
      limit: limit,
      offset: offset,
      type: type,
    );
  }
}
