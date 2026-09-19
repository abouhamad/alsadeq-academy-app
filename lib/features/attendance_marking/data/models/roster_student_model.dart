/// From `GET attendance/roster` (v2 AttendanceController) - a new endpoint
/// we control, so fields are typed exactly.
class RosterStudentModel {
  final int studentId;
  final String fullName;
  final String? rollNo;
  final String? existingStatus;
  final String? existingNote;

  const RosterStudentModel({
    required this.studentId,
    required this.fullName,
    this.rollNo,
    this.existingStatus,
    this.existingNote,
  });

  factory RosterStudentModel.fromJson(Map<String, dynamic> json) => RosterStudentModel(
        studentId: json['student_id'] is int
            ? json['student_id'] as int
            : int.tryParse('${json['student_id']}') ?? 0,
        fullName: (json['full_name'] ?? '').toString(),
        rollNo: json['roll_no']?.toString(),
        existingStatus: json['existing_status']?.toString(),
        existingNote: json['existing_note']?.toString(),
      );
}
