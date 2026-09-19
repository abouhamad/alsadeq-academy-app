import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import 'models/dismissal_record_model.dart';

class DismissalRepository {
  DismissalRepository(this._client);

  final ApiClient _client;

  Future<DismissalRecordModel> scan(String token) async {
    final response = await _client.post<DismissalRecordModel>(
      ApiEndpoints.dismissalScan,
      v2: true,
      body: {'token': token},
      fromData: (json) => DismissalRecordModel.fromJson((json as Map).cast<String, dynamic>()),
    );
    return response.data!;
  }

  Future<List<DismissalRecordModel>> fetchQueue() async {
    final response = await _client.get<dynamic>(ApiEndpoints.dismissalQueue, v2: true);
    return extractJsonList(response.data).map(DismissalRecordModel.fromJson).toList();
  }

  /// Removes one entry - the backend rejects this unless the caller is the
  /// teacher who originally added it.
  Future<void> remove(int id) {
    final path = ApiEndpoints.sub(ApiEndpoints.dismissalRemove, {'id': id});
    return _client.post<dynamic>(path, v2: true);
  }
}
