import '../../domain/entities/attention_item.dart';
import '../../domain/repositories/needs_attention_repository.dart';
import '../datasources/needs_attention_remote_data_source.dart';

class NeedsAttentionRepositoryImpl implements NeedsAttentionRepository {
  final NeedsAttentionRemoteDataSource remoteDataSource;

  NeedsAttentionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AttentionItem>> getNeedsAttention({
    int limit = 10,
    int offset = 0,
    String? type,
  }) async {
    return remoteDataSource.getNeedsAttention(
      limit: limit,
      offset: offset,
      type: type,
    );
  }
}
