class ContactModel {
  final int userId;
  final String name;
  final String kind; // 'teacher' or 'parent'
  final int? studentId;
  final String? studentName;

  const ContactModel({
    required this.userId,
    required this.name,
    required this.kind,
    this.studentId,
    this.studentName,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
        userId: json['user_id'] is int
            ? json['user_id'] as int
            : int.tryParse('${json['user_id']}') ?? 0,
        name: (json['name'] ?? '').toString(),
        kind: (json['kind'] ?? '').toString(),
        studentId: json['student_id'] == null
            ? null
            : (json['student_id'] is int ? json['student_id'] as int : int.tryParse('${json['student_id']}')),
        studentName: json['student_name']?.toString(),
      );
}
