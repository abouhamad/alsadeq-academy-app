class DismissalRecordModel {
  final int id;
  final int studentId;
  final String studentName;
  final String? className;
  final String? sectionName;
  final int? addedByStaffId;
  final String addedByName;

  const DismissalRecordModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.addedByName,
    this.className,
    this.sectionName,
    this.addedByStaffId,
  });

  factory DismissalRecordModel.fromJson(Map<String, dynamic> json) => DismissalRecordModel(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
        studentId: json['student_id'] is int
            ? json['student_id'] as int
            : int.tryParse('${json['student_id']}') ?? 0,
        studentName: (json['student_name'] ?? '').toString(),
        className: json['class_name']?.toString(),
        sectionName: json['section_name']?.toString(),
        addedByStaffId: json['added_by_staff_id'] == null
            ? null
            : (json['added_by_staff_id'] is int
                ? json['added_by_staff_id'] as int
                : int.tryParse('${json['added_by_staff_id']}')),
        addedByName: (json['added_by_name'] ?? '').toString(),
      );
}
