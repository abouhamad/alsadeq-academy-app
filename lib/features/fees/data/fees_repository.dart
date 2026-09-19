import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import '../../auth/data/models/user_model.dart';
import 'models/fees_due_model.dart';

class FeesRepository {
  FeesRepository(this._client);

  final ApiClient _client;

  /// `search-fees-due` (SmApiController@searchFeesDue) is the confirmed v1
  /// route; it's an admin/staff-facing listing in the web app, reused here
  /// filtered by the student's own id for student/parent roles. Verify the
  /// query param name against the live controller if results come back
  /// unfiltered.
  Future<List<FeesDueModel>> fetchFeesDue(UserModel user) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.searchFeesDue,
      query: {'student_id': user.profileRecordId},
    );
    return extractJsonList(response.data).map(FeesDueModel.fromJson).toList();
  }
}
