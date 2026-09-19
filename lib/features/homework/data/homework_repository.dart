import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/role.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import '../../auth/data/models/user_model.dart';
import 'models/homework_model.dart';

class HomeworkRepository {
  HomeworkRepository(this._client);

  final ApiClient _client;

  Future<List<HomeworkModel>> fetchHomework(UserModel user) async {
    late final String path;
    switch (user.role) {
      case AppRole.student:
        path = ApiEndpoints.sub(ApiEndpoints.studentHomework, {'id': user.profileRecordId});
        break;
      case AppRole.parent:
        // A parent has no single "own" record id - profileRecordId falls
        // back to sm_parents.id here, which is the wrong table for this
        // endpoint. Use fetchHomeworkForChild with the child's own
        // student_records id instead (see ChildModel.recordId).
        return const [];
      case AppRole.teacher:
        path = ApiEndpoints.adminTeacherHomework;
        break;
      default:
        return const [];
    }

    final response = await _client.get<dynamic>(path, v2: true);
    return extractJsonList(response.data).map(HomeworkModel.fromJson).toList();
  }

  /// Homework for one of a parent's children, keyed by that child's
  /// `student_records.id` (`ChildModel.recordId`) - what
  /// `parent-homework/{record_id}` actually expects.
  Future<List<HomeworkModel>> fetchHomeworkForChild(int recordId) async {
    final path = ApiEndpoints.sub(ApiEndpoints.parentHomework, {'record_id': recordId});
    final response = await _client.get<dynamic>(path, v2: true);
    return extractJsonList(response.data).map(HomeworkModel.fromJson).toList();
  }
}
