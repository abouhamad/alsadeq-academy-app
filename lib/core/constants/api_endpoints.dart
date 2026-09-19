/// Endpoint paths, relative to [AppConfig.apiV1BaseUrl] or
/// [AppConfig.apiV2BaseUrl] as noted per group. Sourced directly from
/// routes/api.php and routes/v2api.php in the eSkooly Pro backend.
///
/// Path params are left as `{placeholders}` and must be substituted by the
/// caller (see `ApiEndpoints.sub`).
class ApiEndpoints {
  ApiEndpoints._();

  static String sub(String path, Map<String, dynamic> params) {
    var result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', '$value');
    });
    return result;
  }

  // ---- Auth (v2 preferred: routes/v2api.php) ----
  static const String login = 'login'; // v2, any method
  static const String logout = 'auth/logout'; // v2, POST, auth:api
  static const String generalSettings = 'general-settings'; // v2, GET, public
  static const String studentProfileDetails =
      'student-profile-details/{id}'; // v2, GET
  static const String forgetPassword = 'forget-password'; // v2, POST
  static const String me = 'auth/me'; // v2, GET, auth:api

  // ---- Homework (v2, all auth:api) ----
  static const String adminTeacherHomework = 'admin-teacher-homework'; // GET
  static const String studentHomework = 'student-homework/{id}'; // GET
  static const String parentHomework = 'parent-homework/{record_id}'; // GET
  static const String studentHomeworkView =
      'student-homework-view/{class_id}/{section_id}/{homework}'; // GET
  static const String studentHomeworkFileDownload =
      'student-homework-file-download/{id}'; // GET

  // ---- Dashboard (v1: routes/api.php, auth:api) ----
  static const String studentDashboard = 'student-dashboard/{id}'; // GET

  // ---- Notices (v1, auth:api) ----
  static const String studentNoticeboard = 'student-noticeboard/{id}'; // GET

  // ---- Class routine / timetable (v1, auth:api) ----
  static const String classRoutineNew = 'class-routine-new'; // GET
  static const String studentRoutineView =
      'student-routine-view/{student_id}/{record_id}'; // GET
  static const String teacherRoutineView =
      'teacher-routine-view/{techer_id}'; // GET (typo is in backend route)
  static const String myRoutine = 'my-routine/{user_id}'; // GET (teacher)
  static const String childClassRoutine =
      'child-class-routine/{id}'; // GET (parent)

  // ---- Attendance (v1, auth:api) ----
  static const String studentAttendance = 'student-attendance'; // GET
  static const String studentAttendanceStore =
      'student-attendance-store'; // POST (teacher marks attendance)
  static const String studentAttendanceReport =
      'student-attendance-report'; // GET
  static const String myAttendance = 'my-attendance/{id}'; // GET (teacher)

  // ---- Fees (v1, auth:api) ----
  static const String searchFeesDue = 'search-fees-due'; // GET
  static const String feesDueSearch = 'fees-due-search'; // POST
  static const String studentFeesPayment = 'student-fees-payment'; // ANY
  static const String studentFeesInstallments =
      'student-fees-installments/{record_id}'; // GET
  static const String collectFees = 'collect-fees'; // GET/POST
  static const String feesCollectStudentWise =
      'fees-collect-student-wise/{id}'; // GET

  // ---- Exams (v1, auth:api) ----
  static const String onlineExamResult =
      'online-exam-result/{user_id}/{exam_id}/{record_id}'; // GET
  static const String examResult =
      'exam-result/{user_id}/{exam_id}/{record_id}'; // GET
  static const String studentExamSchedule =
      'student-exam-schedule/{student_id}'; // GET
  static const String examRoutineReport = 'exam-routine-report'; // GET

  // ---- Push notifications (v1, auth:api) ----
  static const String setFcmToken = 'set-fcm-token'; // GET, params: id, token

  // ---- Teacher (v1, auth:api) ----
  static const String teacherClassList = 'teacher-class-list'; // GET
  static const String teacherSectionList = 'teacher-section-list'; // GET
  static const String teacherUploadContent = 'teacher-upload-content'; // POST

  // ---- Notices (v2, auth:api, role-aware; replaces studentNoticeboard) ----
  static const String notices = 'notices'; // GET

  // ---- Parent: children list / child schedule (v2) ----
  static const String parentChildren = 'parent/children'; // GET
  static const String parentChildSchedule = 'parent/child-schedule/{studentId}'; // GET

  // ---- Teacher home: day-tagged schedule (v2) ----
  static const String teacherSchedule = 'teacher/schedule'; // GET

  // ---- Attendance marking (v2, teacher) ----
  static const String attendanceRoster = 'attendance/roster'; // GET
  static const String attendanceStore = 'attendance/store'; // POST

  // ---- Pickup / Dismissal (v2) ----
  static const String pickupTokenIssue = 'pickup/token'; // POST (parent)
  static const String dismissalScan = 'dismissal/scan'; // POST (teacher)
  static const String dismissalQueue = 'dismissal/queue'; // GET (teacher)
  static const String dismissalRemove = 'dismissal/{id}/remove'; // POST (teacher, own entries only)

  // ---- Messages (v2) ----
  static const String messagesContacts = 'messages/contacts'; // GET
  static const String messagesThread = 'messages/thread/{userId}'; // GET
  static const String messagesSend = 'messages/send'; // POST
}
