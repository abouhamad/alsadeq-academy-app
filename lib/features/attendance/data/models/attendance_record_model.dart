/// Best-effort mapping — verify field names against the live response of
/// `student-attendance-report` / `my-attendance/{id}` (SmApiController,
/// routes/api.php) once reachable.
class AttendanceRecordModel {
  final Map<String, dynamic> raw;

  const AttendanceRecordModel(this.raw);

  String? get date => _firstString(['attendance_date', 'date']);
  String get status => _firstString(['attendance_type', 'status']) ?? 'unknown';
  String? get note => _firstString(['note', 'remark']);

  String? _firstString(List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return null;
  }

  bool get isPresent => status.toLowerCase().contains('present') || status == '1';
  bool get isAbsent => status.toLowerCase().contains('absent') || status == '2';

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) =>
      AttendanceRecordModel(json);
}
