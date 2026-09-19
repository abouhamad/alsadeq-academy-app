import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import 'models/day_schedule_entry_model.dart';

class TeacherHomeRepository {
  TeacherHomeRepository(this._client);

  final ApiClient _client;

  Future<List<DayScheduleEntryModel>> fetchSchedule() async {
    final response = await _client.get<dynamic>(ApiEndpoints.teacherSchedule, v2: true);
    return extractJsonList(response.data).map(DayScheduleEntryModel.fromJson).toList();
  }
}
