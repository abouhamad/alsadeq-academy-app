import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/role.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import '../../auth/data/models/user_model.dart';
import 'models/routine_entry_model.dart';

class RoutineRepository {
  RoutineRepository(this._client);

  final ApiClient _client;

  Future<List<RoutineEntryModel>> fetchRoutine(UserModel user) async {
    late final String path;
    switch (user.role) {
      case AppRole.student:
        path = ApiEndpoints.sub(
          ApiEndpoints.studentRoutineView,
          {'student_id': user.profileRecordId, 'record_id': user.profileRecordId},
        );
        break;
      case AppRole.parent:
        // profileRecordId resolves to sm_parents.id for a parent, not a
        // student id - use fetchRoutineForChild with the child's own
        // student id instead (see ChildModel.studentId).
        return const [];
      case AppRole.teacher:
        path = ApiEndpoints.sub(ApiEndpoints.myRoutine, {'user_id': user.id});
        break;
      default:
        return const [];
    }

    final response = await _client.get<dynamic>(path);
    return extractJsonList(response.data).map(RoutineEntryModel.fromJson).toList();
  }

  /// Class routine for one of a parent's children, keyed by that child's own
  /// `sm_students.id` (`ChildModel.studentId`). Uses the dedicated v2
  /// endpoint rather than the legacy `child-class-routine/{id}`, which
  /// resolves the student's class/section from `sm_students.class_id`
  /// /`section_id` - columns frequently left null; the v2 endpoint reads the
  /// current assignment from `student_records` instead.
  Future<List<RoutineEntryModel>> fetchRoutineForChild(int studentId) async {
    final path = ApiEndpoints.sub(ApiEndpoints.parentChildSchedule, {'studentId': studentId});
    final response = await _client.get<dynamic>(path, v2: true);
    return extractJsonList(response.data).map(RoutineEntryModel.fromJson).toList();
  }
}
