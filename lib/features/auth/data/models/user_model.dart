import '../../../../core/constants/role.dart';

/// Slim, whitelisted user shape returned by v2 `AuthenticationController@login`
/// (`data.user`): id, full_name, phone_number, role_id, school_id,
/// is_administrator, rtl_ltl, plus one of student_id/parent_id/staff_id.
class UserModel {
  final int id;
  final String fullName;
  final String? phoneNumber;
  final int roleId;
  final int? schoolId;
  final bool isAdministrator;
  final int? studentId;
  final int? parentId;
  final int? staffId;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.roleId,
    this.phoneNumber,
    this.schoolId,
    this.isAdministrator = false,
    this.studentId,
    this.parentId,
    this.staffId,
  });

  AppRole get role => AppRole.fromId(roleId);

  /// The id relevant to "my own record" calls: student's own id for a
  /// student, the linked student id for a parent viewing their child, or
  /// the staff id for a teacher. Falls back to [id].
  int get profileRecordId => studentId ?? parentId ?? staffId ?? id;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _asInt(json['id']) ?? 0,
      fullName: (json['full_name'] ?? json['name'] ?? '').toString(),
      phoneNumber: json['phone_number']?.toString(),
      roleId: _asInt(json['role_id']) ?? -1,
      schoolId: _asInt(json['school_id']),
      isAdministrator: json['is_administrator'] == true || json['is_administrator'] == 1,
      studentId: _asInt(json['student_id']),
      parentId: _asInt(json['parent_id']),
      staffId: _asInt(json['staff_id']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
