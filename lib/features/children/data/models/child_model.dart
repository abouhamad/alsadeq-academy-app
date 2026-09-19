/// A parent's child, as returned by `GET parent/children`
/// (ChildrenController@myChildren). We control this payload, so fields are
/// typed exactly rather than guessed.
class ChildModel {
  final int studentId;
  final int? recordId;
  final String fullName;
  final String? photoUrl;
  final int? classId;
  final String? className;
  final int? sectionId;
  final String? sectionName;

  const ChildModel({
    required this.studentId,
    required this.fullName,
    this.recordId,
    this.photoUrl,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
  });

  String get classSectionLabel =>
      [className, sectionName].whereType<String>().where((s) => s.isNotEmpty).join(' / ');

  factory ChildModel.fromJson(Map<String, dynamic> json) => ChildModel(
        studentId: _asInt(json['student_id']) ?? 0,
        recordId: _asInt(json['record_id']),
        fullName: (json['full_name'] ?? '').toString(),
        photoUrl: json['photo']?.toString(),
        classId: _asInt(json['class_id']),
        className: json['class_name']?.toString(),
        sectionId: _asInt(json['section_id']),
        sectionName: json['section_name']?.toString(),
      );

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
