import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import 'models/notice_model.dart';

class NoticesRepository {
  NoticesRepository(this._client);

  final ApiClient _client;

  /// Role-aware notice board (NoticesController@list) - the backend filters
  /// by the caller's own role_id, so no per-role branching is needed here.
  Future<List<NoticeModel>> fetchNotices() async {
    final response = await _client.get<dynamic>(ApiEndpoints.notices, v2: true);
    return extractJsonList(response.data).map(NoticeModel.fromJson).toList();
  }
}
