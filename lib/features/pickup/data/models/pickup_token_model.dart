class PickupTokenModel {
  final String token;
  final int studentId;
  final String studentName;
  final DateTime expiresAt;

  const PickupTokenModel({
    required this.token,
    required this.studentId,
    required this.studentName,
    required this.expiresAt,
  });

  factory PickupTokenModel.fromJson(Map<String, dynamic> json) => PickupTokenModel(
        token: (json['token'] ?? '').toString(),
        studentId: json['student_id'] is int
            ? json['student_id'] as int
            : int.tryParse('${json['student_id']}') ?? 0,
        studentName: (json['student_name'] ?? '').toString(),
        expiresAt: DateTime.tryParse('${json['expires_at']}') ?? DateTime.now(),
      );
}
