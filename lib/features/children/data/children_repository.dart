import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import 'models/child_model.dart';

class ChildrenRepository {
  ChildrenRepository(this._client);

  final ApiClient _client;

  Future<List<ChildModel>> fetchChildren() async {
    final response = await _client.get<dynamic>(ApiEndpoints.parentChildren, v2: true);
    return extractJsonList(response.data).map(ChildModel.fromJson).toList();
  }
}
