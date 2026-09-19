/// Best-effort mapping of the homework JSON returned by
/// `student-homework/{id}` / `parent-homework/{record_id}` /
/// `admin-teacher-homework` (v2 HomeworkController). Field names weren't
/// fully confirmed against a live response, so each getter tries a few
/// likely key spellings — verify against the real payload once the API is
/// reachable and tighten this model.
class HomeworkModel {
  final Map<String, dynamic> raw;

  const HomeworkModel(this.raw);

  int get id => _asInt(raw['id']) ?? 0;
  String get title => _firstString(['title', 'homework_title', 'name']) ?? 'Homework';
  String? get subject => _firstString(['subject_name', 'subject']);
  String? get description => _firstString(['description', 'details', 'message']);
  String? get homeworkDate => _firstString(['homework_date', 'date', 'created_at']);
  String? get submissionDate => _firstString(['submission_date', 'due_date']);
  String? get fileUrl => _firstString(['upload_file', 'file', 'attachment']);

  String? _firstString(List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  factory HomeworkModel.fromJson(Map<String, dynamic> json) => HomeworkModel(json);
}
