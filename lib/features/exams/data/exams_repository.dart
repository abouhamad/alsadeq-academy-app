import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/utils/json_list.dart';
import '../../auth/data/models/user_model.dart';
import 'models/exam_schedule_model.dart';

class ExamsRepository {
  ExamsRepository(this._client);

  final ApiClient _client;

  /// Exam *results* (`online-exam-result/{user_id}/{exam_id}/{record_id}`)
  /// need an exam id we don't have without a prior "my exams" listing call
  /// that wasn't part of the mapped route set, so this scaffold surfaces
  /// the exam *schedule* instead (`student-exam-schedule/{student_id}`),
  /// which only needs the student's own id and is fully wireable today.
  /// Swap in the results endpoint once the exam-listing call is confirmed.
  Future<List<ExamScheduleModel>> fetchExamSchedule(UserModel user) async {
    final path = ApiEndpoints.sub(
      ApiEndpoints.studentExamSchedule,
      {'student_id': user.profileRecordId},
    );
    final response = await _client.get<dynamic>(path);
    return extractJsonList(response.data).map(ExamScheduleModel.fromJson).toList();
  }
}
