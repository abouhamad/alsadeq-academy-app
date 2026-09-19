class ExamScheduleModel {
  final Map<String, dynamic> raw;

  const ExamScheduleModel(this.raw);

  String get examName => _firstString(['exam_name', 'name']) ?? 'Exam';
  String? get subject => _firstString(['subject_name', 'subject']);
  String? get date => _firstString(['exam_date', 'date']);
  String? get startTime => _firstString(['start_time']);
  String? get endTime => _firstString(['end_time']);

  String? _firstString(List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return null;
  }

  factory ExamScheduleModel.fromJson(Map<String, dynamic> json) => ExamScheduleModel(json);
}
