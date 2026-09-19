import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import 'models/class_option_model.dart';
import 'models/roster_student_model.dart';
import 'models/section_option_model.dart';

class AttendanceMarkingRepository {
  AttendanceMarkingRepository(this._client);

  final ApiClient _client;

  Future<List<ClassOptionModel>> fetchClasses(int userId) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.teacherClassList,
      query: {'id': userId},
    );
    return extractJsonList(response.data).map(ClassOptionModel.fromJson).toList();
  }

  Future<List<SectionOptionModel>> fetchSections(int userId, int classId) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.teacherSectionList,
      query: {'id': userId, 'class': classId},
    );
    return extractJsonList(response.data).map(SectionOptionModel.fromJson).toList();
  }

  Future<List<RosterStudentModel>> fetchRoster({
    required int classId,
    required int sectionId,
    required String date,
  }) async {
    final response = await _client.get<dynamic>(
      ApiEndpoints.attendanceRoster,
      v2: true,
      query: {'class_id': classId, 'section_id': sectionId, 'date': date},
    );
    final data = response.data;
    final students = (data is Map ? data['students'] : null) as List<dynamic>?;
    return (students ?? const [])
        .whereType<Map>()
        .map((e) => RosterStudentModel.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> saveAttendance({
    required int classId,
    required int sectionId,
    required String date,
    required List<Map<String, dynamic>> records,
  }) {
    return _client.post<dynamic>(
      ApiEndpoints.attendanceStore,
      v2: true,
      body: {
        'class_id': classId,
        'section_id': sectionId,
        'date': date,
        'records': records,
      },
    );
  }
}
