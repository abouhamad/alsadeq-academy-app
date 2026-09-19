import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/role.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import '../../auth/data/models/user_model.dart';
import 'models/attendance_record_model.dart';

class AttendanceRepository {
  AttendanceRepository(this._client);

  final ApiClient _client;

  /// NOTE: exact query params for these v1 endpoints weren't confirmed from
  /// source during scaffolding (SmApiController's attendance methods weren't
  /// read in full) — `id` is the safest guess based on the sibling
  /// `*-view/{id}` pattern used everywhere else in routes/api.php. Verify
  /// against the live API and adjust here; the UI layer doesn't need to
  /// change.
  Future<List<AttendanceRecordModel>> fetchAttendance(UserModel user) async {
    switch (user.role) {
      case AppRole.student:
      case AppRole.parent:
        final response = await _client.get<dynamic>(
          ApiEndpoints.studentAttendanceReport,
          query: {'id': user.profileRecordId},
        );
        return extractJsonList(response.data).map(AttendanceRecordModel.fromJson).toList();
      case AppRole.teacher:
        final path = ApiEndpoints.sub(ApiEndpoints.myAttendance, {'id': user.profileRecordId});
        final response = await _client.get<dynamic>(path);
        return extractJsonList(response.data).map(AttendanceRecordModel.fromJson).toList();
      default:
        return const [];
    }
  }
}
