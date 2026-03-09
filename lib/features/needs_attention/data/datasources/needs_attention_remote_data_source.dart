import 'package:guidr/core/network/api_client.dart';
import '../../domain/entities/attention_item.dart';

abstract class NeedsAttentionRemoteDataSource {
  Future<List<AttentionItem>> getNeedsAttention({
    int limit = 10,
    int offset = 0,
    String? type,
  });
}

class NeedsAttentionRemoteDataSourceImpl
    implements NeedsAttentionRemoteDataSource {
  final ApiClient apiClient;

  NeedsAttentionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<AttentionItem>> getNeedsAttention({
    int limit = 10,
    int offset = 0,
    String? type,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    final queryString = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final endpoint = '/coaches/alerts?$queryString';

    final response = await apiClient.get(endpoint);
    List data = [];
    if (response['data'] is List) {
      data = response['data'] as List;
    } else if (response is List) {
      data = response as List;
    }
    return data
        .map((e) => AttentionItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
